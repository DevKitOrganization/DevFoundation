//
//  LiveQuery.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 10/23/2025.
//

import AsyncAlgorithms
import Foundation
import Observation
import Synchronization

/// An observable query that produces results as its fragment changes.
///
/// Live queries manage the lifecycle of producing results as users type. Set the ``queryFragment`` property and observe
/// ``results`` for updates. The query automatically handles scheduling, deduplication, and caching.
///
///
/// ## Overview
///
/// `LiveQuery` provides a reactive interface for search-as-you-type functionality. It coordinates between user input
/// and result production, handling common concerns like debouncing, duplicate removal, cancellation, and error
/// management.
///
/// Live queries get results from a producer. A ``LiveQueryResultsProducer`` produces results once for each query
/// fragment, which works well for searches whose results don’t change, like network requests. A
/// ``LiveQueryResultUpdatesProducer`` produces a sequence of results for each query fragment, which works well for
/// searches over local data that should update when the data changes. In both cases, results for a query fragment are
/// only used until the query fragment changes. When it does, the live query cancels result production for the previous
/// fragment and discards any results it produces later.
///
///
/// ## Usage
///
/// Create a live query by providing a ``LiveQueryResultsProducer`` that defines how to generate results:
///
///     struct SearchProducer: LiveQueryResultsProducer {
///         var schedulingStrategy: LiveQuerySchedulingStrategy {
///             .debounce(.milliseconds(300))
///         }
///
///         func results(forQueryFragment queryFragment: String) async throws -> [SearchResult] {
///             // Perform search and return results
///         }
///     }
///
///     let liveQuery = LiveQuery(resultsProducer: SearchProducer())
///
/// If results can change after they’re produced, provide a ``LiveQueryResultUpdatesProducer`` instead:
///
///     let liveQuery = LiveQuery(resultUpdatesProducer: NoteSearchProducer(noteStore: noteStore))
///
/// Update the query fragment to trigger result production:
///
///     liveQuery.queryFragment = "search term"
///
/// Observe results using SwiftUI or the Observation framework:
///
///     @State var liveQuery = LiveQuery(resultsProducer: SearchProducer())
///
///     var body: some View {
///         List(liveQuery.results ?? []) { result in
///             Text(result.title)
///         }
///         .searchable(text: $liveQuery.queryFragment)
///     }
///
///
/// ## Scheduling Strategies
///
/// The producer’s scheduling strategy determines when results are generated:
///
///   - ``LiveQuerySchedulingStrategy/passthrough``: Produces results immediately for every change. Best for cheap
///     operations like filtering local data.
///   - ``LiveQuerySchedulingStrategy/debounce(_:)``: Waits for typing to pause before producing results. Best for
///     expensive operations like network requests.
///
///
/// ## Error Handling
///
/// Errors from result production are captured in ``lastError``. The query continues operating after errors,
/// preserving the last successful results until new ones are produced.
///
/// When a result updates sequence throws an error, the live query sets ``lastError`` and stops iterating that
/// sequence, keeping its last results. Changing the query fragment starts a new sequence, and its first value clears
/// ``lastError``. Errors from a sequence that was cancelled because the query fragment changed are ignored.
///
///
/// ## Thread Safety
///
/// `LiveQuery` is fully thread-safe and `Sendable`. All properties can be accessed from any thread, though
/// observation notifications follow the standard Observation framework behavior.
///
///
/// ## Performance
///
/// The query automatically deduplicates identical fragments and canonicalizes input through the producer. This
/// prevents unnecessary work when users make redundant changes.
@Observable
public final class LiveQuery<Results>: Sendable where Results: Sendable {
    /// The query’s mutable state.
    private struct State {
        /// The current query fragment.
        var queryFragment: String = ""

        /// The latest results.
        var results: Results?

        /// The last error that occurred.
        var lastError: (any Error)?

        /// The task that handles inputs.
        var inputHandlingTask: Task<Void, Never>?

        /// The task that iterates the current query fragment’s result updates.
        var resultUpdatesTask: Task<Void, Never>?

        /// The generation of the current query fragment’s result updates.
        ///
        /// This is incremented each time result updates start for a new query fragment. Result updates only change the
        /// query’s state if their generation matches this one.
        var resultUpdatesGeneration: UInt64 = 0
    }


    /// A mutex that synchronizes access to the query’s mutable state.
    private let stateMutex = Mutex(State())

    /// A continuation used to yield query fragment changes to the input handling task.
    private let queryFragmentContinuation: AsyncStream<String>.Continuation

    /// The producer used to generate result updates.
    private let resultUpdatesProducer: any LiveQueryResultUpdatesProducer<Results>


    /// Creates a live query with the specified result updates producer.
    ///
    /// Each time the query fragment changes, the live query iterates the result updates for the new query fragment,
    /// updating ``results`` with each value. It cancels its iteration of the previous query fragment’s result updates.
    ///
    /// - Parameter resultUpdatesProducer: The producer used to generate result updates.
    public init(resultUpdatesProducer: some LiveQueryResultUpdatesProducer<Results>) {
        self.resultUpdatesProducer = resultUpdatesProducer

        let (queryFragmentStream, queryFragmentContinuation) = AsyncStream<String>.makeStream()
        self.queryFragmentContinuation = queryFragmentContinuation

        let queryFragmentValues = queryFragmentStream.schedule(with: resultUpdatesProducer.schedulingStrategy)
        let task = Task { [weak self] in
            for await queryFragment in queryFragmentValues {
                guard let self else {
                    return
                }

                startResultUpdates(forQueryFragment: queryFragment)
            }
        }

        stateMutex.withLock { $0.inputHandlingTask = task }
    }


    /// Creates a live query with the specified results producer.
    ///
    /// Each time the query fragment changes, the live query produces results for the new query fragment. If results for
    /// the previous query fragment are still being produced, the live query cancels their production and discards them.
    ///
    /// - Parameter resultsProducer: The producer used to generate results.
    public convenience init(resultsProducer: some LiveQueryResultsProducer<Results>) {
        self.init(resultUpdatesProducer: resultsProducer)
    }


    deinit {
        stateMutex.withLock { state in
            state.inputHandlingTask?.cancel()
            state.resultUpdatesTask?.cancel()
        }
        queryFragmentContinuation.finish()
    }


    /// The current query fragment.
    ///
    /// Updates trigger result production based on the scheduling strategy. If the producer’s
    /// ``LiveQueryResultUpdatesProducer/canonicalQueryFragment(from:)`` returns `nil` for the new value, the update
    /// doesn’t trigger result production. The query keeps its results, and if the previous query fragment’s result
    /// updates haven’t finished, the query keeps iterating them. With the default canonicalization, this happens
    /// when the query fragment is empty or contains only whitespace.
    public var queryFragment: String {
        get {
            access(keyPath: \.queryFragment)
            return stateMutex.withLock(\.queryFragment)
        }

        set {
            withMutation(keyPath: \.queryFragment) {
                stateMutex.withLock { $0.queryFragment = newValue }
            }

            if let canonicalQueryFragment = resultUpdatesProducer.canonicalQueryFragment(from: newValue) {
                queryFragmentContinuation.yield(canonicalQueryFragment)
            }
        }
    }


    /// The most recent query results, or `nil` if none have been produced yet.
    public var results: Results? {
        access(keyPath: \.results)
        return stateMutex.withLock(\.results)
    }


    /// The error that occurred the last time we produced results, or `nil` if none occurred.
    public var lastError: (any Error)? {
        access(keyPath: \.lastError)
        return stateMutex.withLock(\.lastError)
    }


    /// Starts iterating the result updates for a query fragment, cancelling the previous fragment’s result updates.
    ///
    /// - Parameter queryFragment: The canonical query fragment whose result updates are iterated.
    private func startResultUpdates(forQueryFragment queryFragment: String) {
        let resultUpdates = resultUpdatesProducer.resultUpdates(forQueryFragment: queryFragment)

        stateMutex.withLock { state in
            state.resultUpdatesTask?.cancel()
            state.resultUpdatesGeneration += 1

            let generation = state.resultUpdatesGeneration
            state.resultUpdatesTask = Task { [weak self] in
                do {
                    for try await results in resultUpdates {
                        // Stop iterating once we’re deallocated, even if the sequence ignores cancellation
                        guard let self else {
                            return
                        }

                        update(results: results, generation: generation)
                    }
                } catch {
                    self?.update(error: error, generation: generation)
                }
            }
        }
    }


    /// Sets the query’s results and clears its last error if the generation is current.
    ///
    /// - Parameters:
    ///   - results: The new results.
    ///   - generation: The generation of the result updates that produced the results.
    private func update(results: Results, generation: UInt64) {
        // Check the generation before notifying observers so that rejected writes don’t cause spurious notifications.
        // We check again when writing, because the generation can change in between.
        guard isCurrent(generation) else {
            return
        }

        _$observationRegistrar.willSet(self, keyPath: \.lastError)
        _$observationRegistrar.willSet(self, keyPath: \.results)
        stateMutex.withLock { state in
            guard state.resultUpdatesGeneration == generation else {
                return
            }

            state.results = results
            state.lastError = nil
        }
        _$observationRegistrar.didSet(self, keyPath: \.results)
        _$observationRegistrar.didSet(self, keyPath: \.lastError)
    }


    /// Sets the query’s last error if the generation is current.
    ///
    /// - Parameters:
    ///   - error: The error that occurred.
    ///   - generation: The generation of the result updates that produced the error.
    private func update(error: any Error, generation: UInt64) {
        guard isCurrent(generation) else {
            return
        }

        withMutation(keyPath: \.lastError) {
            stateMutex.withLock { state in
                guard state.resultUpdatesGeneration == generation else {
                    return
                }

                state.lastError = error
            }
        }
    }


    /// Returns whether the specified generation is the generation of the current query fragment’s result updates.
    ///
    /// - Parameter generation: The generation to check.
    private func isCurrent(_ generation: UInt64) -> Bool {
        return stateMutex.withLock { $0.resultUpdatesGeneration == generation }
    }
}


extension AsyncSequence where Self: Sendable, Element: Equatable & Sendable {
    /// Applies modifiers to the input stream so that it delivers values according to the strategy.
    ///
    /// - Parameter inputSequence: The input sequence to modify.
    /// - Returns: A sequence with duplicates removed and the appropriate timing strategy applied.
    fileprivate func schedule(
        with strategy: LiveQuerySchedulingStrategy
    ) -> any AsyncSequence<Element, Failure> {
        let deduplicated = removeDuplicates()

        switch strategy.strategy {
        case .passthrough:
            return deduplicated
        case .debounce(let duration):
            return deduplicated.debounce(for: duration)
        }
    }
}
