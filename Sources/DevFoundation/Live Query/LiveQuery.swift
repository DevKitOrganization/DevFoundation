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
/// and result production, handling common concerns like debouncing, duplicate removal, and error management.
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
/// The results producer’s ``LiveQueryResultsProducer/schedulingStrategy`` determines when results are generated:
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
///
/// ## Thread Safety
///
/// `LiveQuery` is fully thread-safe and `Sendable`. All properties can be accessed from any thread, though
/// observation notifications follow the standard Observation framework behavior.
///
///
/// ## Performance
///
/// The query automatically deduplicates identical fragments and canonicalizes input through the results producer.
/// This prevents unnecessary work when users make redundant changes.
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
    }

    /// A mutex that synchronizes access to the query’s mutable state.
    private let stateMutex = Mutex(State())

    /// A continuation used to yield query fragment changes to the input handling task.
    private let queryFragmentContinuation: AsyncStream<String>.Continuation

    /// The results producer used to generate results.
    private let resultsProducer: any LiveQueryResultsProducer<Results>


    /// Creates a live query with the specified results producer.
    ///
    /// - Parameter resultsProducer: The producer used to generate results.
    public init(resultsProducer: some LiveQueryResultsProducer<Results>) {
        self.resultsProducer = resultsProducer

        let (queryFragmentStream, queryFragmentContinuation) = AsyncStream<String>.makeStream()
        self.queryFragmentContinuation = queryFragmentContinuation

        let queryFragmentValues = queryFragmentStream.schedule(with: resultsProducer.schedulingStrategy)
        let task = Task { [weak self] in
            for await queryFragment in queryFragmentValues {
                guard let self else {
                    return
                }

                do {
                    let results = try await resultsProducer.results(forQueryFragment: queryFragment)

                    _$observationRegistrar.willSet(self, keyPath: \.lastError)
                    _$observationRegistrar.willSet(self, keyPath: \.results)
                    stateMutex.withLock { state in
                        state.results = results
                        state.lastError = nil
                    }
                    _$observationRegistrar.didSet(self, keyPath: \.results)
                    _$observationRegistrar.didSet(self, keyPath: \.lastError)
                } catch {
                    withMutation(keyPath: \.lastError) {
                        stateMutex.withLock { $0.lastError = error }
                    }
                }
            }
        }

        stateMutex.withLock { $0.inputHandlingTask = task }
    }


    deinit {
        stateMutex.withLock { $0.inputHandlingTask?.cancel() }
        queryFragmentContinuation.finish()
    }


    /// The current query fragment.
    ///
    /// Updates trigger result production based on the scheduling strategy.
    public var queryFragment: String {
        get {
            access(keyPath: \.queryFragment)
            return stateMutex.withLock(\.queryFragment)
        }

        set {
            withMutation(keyPath: \.queryFragment) {
                stateMutex.withLock { $0.queryFragment = newValue }
            }

            if let canonicalQueryFragment = resultsProducer.canonicalQueryFragment(from: newValue) {
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
