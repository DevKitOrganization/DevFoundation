//
//  LiveQueryTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 10/24/2025.
//

import DevTesting
import Foundation
import Observation
import Synchronization
import Testing

@testable import DevFoundation

struct LiveQueryTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    // MARK: - Initialization

    @Test
    mutating func initializationSetsCorrectDefaults() {
        // set up the test by creating a mock results producer
        let resultsProducer = MockLiveQueryResultsProducer<[String]>()
        resultsProducer.schedulingStrategyStub = Stub(defaultReturnValue: randomLiveQuerySchedulingStrategy())
        resultsProducer.canonicalQueryFragmentStub = Stub(defaultReturnValue: nil)

        // exercise the test by initializing a live query
        let liveQuery = LiveQuery(resultsProducer: resultsProducer)

        // expect the initial state is correct
        #expect(liveQuery.queryFragment == "")
        #expect(liveQuery.results == nil)
        #expect(liveQuery.lastError == nil)
    }


    // MARK: - queryFragment

    @Test
    mutating func settingQueryFragmentThatCanonicalizesToNilDoesNotCallResultsProducer() async throws {
        // set up the test by creating a mock results producer
        let resultsProducer = MockLiveQueryResultsProducer<[String]>()
        resultsProducer.schedulingStrategyStub = Stub(defaultReturnValue: .passthrough)
        resultsProducer.canonicalQueryFragmentStub = Stub(defaultReturnValue: nil)
        resultsProducer.resultsStub = ThrowingStub(defaultReturnValue: [randomAlphanumericString()])

        let liveQuery = LiveQuery(resultsProducer: resultsProducer)

        // exercise the test by setting a query fragment that canonicalizes to nil
        liveQuery.queryFragment = randomAlphanumericString()

        // wait briefly to ensure no call happens
        try await Task.sleep(for: .milliseconds(50))

        // expect the results producer was not called
        #expect(resultsProducer.resultsStub.calls.isEmpty)
    }


    @Test
    mutating func settingQueryFragmentsWithSameCanonicalFormDeduplicatesCalls() async throws {
        // set up the test by creating a mock results producer with epilogue
        let resultsProducer = MockLiveQueryResultsProducer<[String]>()
        resultsProducer.schedulingStrategyStub = Stub(defaultReturnValue: .passthrough)

        let canonicalFragment = randomAlphanumericString()
        resultsProducer.canonicalQueryFragmentStub = Stub(defaultReturnValue: canonicalFragment)
        resultsProducer.resultsStub = ThrowingStub(defaultReturnValue: [randomAlphanumericString()])

        let (signalStream, signaler) = AsyncStream<Void>.makeStream()
        resultsProducer.resultsEpilogue = {
            signaler.yield()
        }

        let liveQuery = LiveQuery(resultsProducer: resultsProducer)

        let fragment1 = randomAlphanumericString()
        let fragment2 = randomAlphanumericString()

        // exercise the test by setting two different query fragments that canonicalize to the same value
        liveQuery.queryFragment = fragment1
        liveQuery.queryFragment = fragment2

        // wait for the first call to complete
        await signalStream.first { @Sendable _ in true }

        // expect canonicalQueryFragment was called twice with correct arguments
        #expect(resultsProducer.canonicalQueryFragmentStub.callArguments == [fragment1, fragment2])

        // expect the results producer was called only once with the canonical fragment
        #expect(resultsProducer.resultsStub.callArguments == [canonicalFragment])
    }


    // MARK: - results

    @MainActor @Test
    mutating func settingValidQueryFragmentProducesResults() async throws {
        // set up the test by creating a mock results producer
        let resultsProducer = MockLiveQueryResultsProducer<[String]>()
        resultsProducer.schedulingStrategyStub = Stub(defaultReturnValue: .passthrough)

        let queryFragment = randomAlphanumericString()
        resultsProducer.canonicalQueryFragmentStub = Stub(defaultReturnValue: queryFragment)

        let expectedResults = [randomAlphanumericString(), randomAlphanumericString()]
        resultsProducer.resultsStub = ThrowingStub(defaultReturnValue: expectedResults)

        let liveQuery = LiveQuery(resultsProducer: resultsProducer)

        // exercise the test by setting a valid query fragment
        liveQuery.queryFragment = queryFragment

        // wait for results to be produced
        _ = await Observations({ liveQuery.results }).first { @Sendable in $0 == expectedResults }

        // expect the results match what the producer returned
        #expect(liveQuery.results == expectedResults)
        #expect(resultsProducer.resultsStub.callArguments == [queryFragment])
    }


    // MARK: - lastError

    @MainActor @Test
    mutating func errorFromProducerUpdatesLastErrorAndPreservesResults() async throws {
        // set up the test by creating a mock results producer
        let resultsProducer = MockLiveQueryResultsProducer<[String]>()
        resultsProducer.schedulingStrategyStub = Stub(defaultReturnValue: .passthrough)

        let fragment1 = randomAlphanumericString()
        let fragment2 = randomAlphanumericString()
        let canonicalFragment1 = randomAlphanumericString()
        let canonicalFragment2 = randomAlphanumericString()
        resultsProducer.canonicalQueryFragmentStub = Stub(
            defaultReturnValue: canonicalFragment2,
            returnValueQueue: [canonicalFragment1],
        )

        let initialResults = [randomAlphanumericString()]
        let expectedError = randomError()
        resultsProducer.resultsStub = ThrowingStub(
            defaultError: expectedError,
            resultQueue: [.success(initialResults)],
        )

        let liveQuery = LiveQuery(resultsProducer: resultsProducer)

        // exercise the test by first producing successful results
        liveQuery.queryFragment = fragment1
        _ = await Observations({ liveQuery.results }).first { @Sendable in $0 == initialResults }

        #expect(liveQuery.lastError == nil)

        // exercise the test by producing an error
        liveQuery.queryFragment = fragment2
        _ = await Observations({ liveQuery.lastError != nil }).first { @Sendable in $0 }

        // expect the error is captured and previous results are preserved
        #expect(liveQuery.results == initialResults)
        #expect(liveQuery.lastError as? ArbitraryError == expectedError)
    }


    @MainActor @Test
    mutating func successfulResultAfterErrorClearsLastError() async throws {
        // set up the test by creating a mock results producer
        let resultsProducer = MockLiveQueryResultsProducer<[String]>()
        resultsProducer.schedulingStrategyStub = Stub(defaultReturnValue: .passthrough)

        let fragment1 = randomAlphanumericString()
        let fragment2 = randomAlphanumericString()
        let canonicalFragment1 = randomAlphanumericString()
        let canonicalFragment2 = randomAlphanumericString()
        resultsProducer.canonicalQueryFragmentStub = Stub(
            defaultReturnValue: canonicalFragment2,
            returnValueQueue: [canonicalFragment1],
        )

        let expectedError = randomError()
        let newResults = [randomAlphanumericString()]
        resultsProducer.resultsStub = ThrowingStub(
            defaultReturnValue: newResults,
            resultQueue: [.failure(expectedError)],
        )

        let liveQuery = LiveQuery(resultsProducer: resultsProducer)

        // exercise the test by first producing an error
        liveQuery.queryFragment = fragment1
        _ = await Observations({ liveQuery.lastError != nil }).first { @Sendable in $0 }

        #expect(liveQuery.results == nil)
        #expect(liveQuery.lastError as? ArbitraryError == expectedError)

        // exercise the test by producing successful results
        liveQuery.queryFragment = fragment2
        _ = await Observations({ liveQuery.results }).first { @Sendable in $0 == newResults }

        // expect the error is cleared
        #expect(liveQuery.results == newResults)
        #expect(liveQuery.lastError == nil)
    }


    // MARK: - Scheduling Strategies

    @MainActor @Test
    mutating func passthroughStrategyProducesResultsForAllFragments() async throws {
        // set up the test by creating a mock results producer with passthrough strategy
        let resultsProducer = MockLiveQueryResultsProducer<[String]>()
        resultsProducer.schedulingStrategyStub = Stub(defaultReturnValue: .passthrough)

        let canonicalFragment1 = randomAlphanumericString()
        let canonicalFragment2 = randomAlphanumericString()
        let canonicalFragment3 = randomAlphanumericString()
        resultsProducer.canonicalQueryFragmentStub = Stub(
            defaultReturnValue: canonicalFragment3,
            returnValueQueue: [canonicalFragment1, canonicalFragment2],
        )

        let results1 = [randomAlphanumericString()]
        let results2 = [randomAlphanumericString()]
        let results3 = [randomAlphanumericString()]
        resultsProducer.resultsStub = ThrowingStub(
            defaultReturnValue: results3,
            resultQueue: [.success(results1), .success(results2)],
        )

        let liveQuery = LiveQuery(resultsProducer: resultsProducer)

        // exercise the test by setting multiple query fragments, waiting for each one’s results
        liveQuery.queryFragment = randomAlphanumericString()
        _ = await Observations({ liveQuery.results }).first { @Sendable in $0 == results1 }

        liveQuery.queryFragment = randomAlphanumericString()
        _ = await Observations({ liveQuery.results }).first { @Sendable in $0 == results2 }

        liveQuery.queryFragment = randomAlphanumericString()
        _ = await Observations({ liveQuery.results }).first { @Sendable in $0 == results3 }

        // expect all three results were produced
        #expect(
            resultsProducer.resultsStub.callArguments == [canonicalFragment1, canonicalFragment2, canonicalFragment3]
        )
    }


    @MainActor @Test
    mutating func debounceStrategyDelaysResultProduction() async throws {
        // set up the test by creating a mock results producer with debounce strategy
        let resultsProducer = MockLiveQueryResultsProducer<[String]>()
        let debounceDuration = Duration.milliseconds(200)
        resultsProducer.schedulingStrategyStub = Stub(defaultReturnValue: .debounce(debounceDuration))

        let canonicalFragment = randomAlphanumericString()
        resultsProducer.canonicalQueryFragmentStub = Stub(defaultReturnValue: canonicalFragment)

        let expectedResults = [randomAlphanumericString()]
        resultsProducer.resultsStub = ThrowingStub(defaultReturnValue: expectedResults)

        let liveQuery = LiveQuery(resultsProducer: resultsProducer)

        // exercise the test by setting a query fragment
        liveQuery.queryFragment = randomAlphanumericString()

        // expect results are not immediately available
        try await Task.sleep(for: .milliseconds(50))
        #expect(liveQuery.results == nil)
        #expect(resultsProducer.resultsStub.callArguments.isEmpty)

        // wait for debounce to complete
        _ = await Observations({ liveQuery.results }).first { @Sendable in $0 == expectedResults }

        // expect results are now available
        #expect(liveQuery.results == expectedResults)
        #expect(resultsProducer.resultsStub.callArguments == [canonicalFragment])
    }


    // MARK: - Result Updates

    @Test
    mutating func initializationWithResultUpdatesProducerSetsCorrectDefaults() {
        // set up the test by creating a mock result updates producer
        let resultUpdatesProducer = StreamResultUpdatesProducer()
        resultUpdatesProducer.schedulingStrategyStub = Stub(defaultReturnValue: randomLiveQuerySchedulingStrategy())

        // exercise the test by initializing a live query
        let liveQuery = LiveQuery(resultUpdatesProducer: resultUpdatesProducer)

        // expect the initial state is correct
        #expect(liveQuery.queryFragment == "")
        #expect(liveQuery.results == nil)
        #expect(liveQuery.lastError == nil)
    }


    @MainActor @Test
    mutating func eachValueFromResultUpdatesUpdatesResults() async throws {
        // set up the test by creating a mock result updates producer that returns a stream
        let resultUpdatesProducer = StreamResultUpdatesProducer()
        resultUpdatesProducer.schedulingStrategyStub = Stub(defaultReturnValue: .passthrough)

        let canonicalFragment = randomAlphanumericString()
        resultUpdatesProducer.canonicalQueryFragmentStub = Stub(defaultReturnValue: canonicalFragment)

        let (resultUpdates, resultUpdatesContinuation) = AsyncThrowingStream<[String], any Error>.makeStream()
        resultUpdatesProducer.resultUpdatesStub = Stub(defaultReturnValue: resultUpdates)

        let liveQuery = LiveQuery(resultUpdatesProducer: resultUpdatesProducer)

        let results1 = [randomAlphanumericString()]
        let results2 = [randomAlphanumericString()]

        // exercise the test by setting a query fragment and producing two values
        liveQuery.queryFragment = randomAlphanumericString()

        // expect each value updates the results
        resultUpdatesContinuation.yield(results1)
        _ = await Observations({ liveQuery.results }).first { @Sendable in $0 == results1 }

        resultUpdatesContinuation.yield(results2)
        _ = await Observations({ liveQuery.results }).first { @Sendable in $0 == results2 }

        #expect(resultUpdatesProducer.resultUpdatesStub.callArguments == [canonicalFragment])
    }


    @MainActor @Test
    mutating func changingQueryFragmentCancelsPreviousResultUpdates() async throws {
        // set up the test by creating a mock result updates producer whose first stream signals its termination
        let resultUpdatesProducer = StreamResultUpdatesProducer()
        resultUpdatesProducer.schedulingStrategyStub = Stub(defaultReturnValue: .passthrough)

        let canonicalFragment1 = randomAlphanumericString()
        let canonicalFragment2 = randomAlphanumericString()
        resultUpdatesProducer.canonicalQueryFragmentStub = Stub(
            defaultReturnValue: canonicalFragment2,
            returnValueQueue: [canonicalFragment1],
        )

        let (terminationStream, terminationSignaler) = AsyncStream<Void>.makeStream()
        let (resultUpdates1, resultUpdatesContinuation1) = AsyncThrowingStream<[String], any Error>.makeStream()
        resultUpdatesContinuation1.onTermination = { _ in
            terminationSignaler.yield()
        }

        let (resultUpdates2, _) = AsyncThrowingStream<[String], any Error>.makeStream()
        resultUpdatesProducer.resultUpdatesStub = Stub(
            defaultReturnValue: resultUpdates2,
            returnValueQueue: [resultUpdates1],
        )

        let liveQuery = LiveQuery(resultUpdatesProducer: resultUpdatesProducer)

        let results1 = [randomAlphanumericString()]
        liveQuery.queryFragment = randomAlphanumericString()
        resultUpdatesContinuation1.yield(results1)
        _ = await Observations({ liveQuery.results }).first { @Sendable in $0 == results1 }

        // exercise the test by changing the query fragment
        liveQuery.queryFragment = randomAlphanumericString()

        // expect the first fragment’s result updates are cancelled
        await terminationStream.first { @Sendable _ in true }
        #expect(resultUpdatesProducer.resultUpdatesStub.callArguments == [canonicalFragment1, canonicalFragment2])
        #expect(liveQuery.results == results1)
    }


    @MainActor @Test
    mutating func valuesFromSupersededResultUpdatesAreIgnored() async throws {
        // set up the test by creating a mock result updates producer whose first sequence ignores cancellation and
        // produces a stale value when the test opens a gate
        let resultUpdatesProducer = ClosureResultUpdatesProducer()
        resultUpdatesProducer.schedulingStrategyStub = Stub(defaultReturnValue: .passthrough)
        resultUpdatesProducer.canonicalQueryFragmentStub = Stub(
            defaultReturnValue: randomAlphanumericString(),
            returnValueQueue: [randomAlphanumericString()],
        )

        let results1 = [randomAlphanumericString()]
        let staleResults = [randomAlphanumericString()]
        let results2 = [randomAlphanumericString()]

        let (waitingStream, waitingSignaler) = AsyncStream<Void>.makeStream()
        let (gateStream, gateSignaler) = AsyncStream<Void>.makeStream()
        let (handledStream, handledSignaler) = AsyncStream<Void>.makeStream()
        let resultUpdates1 = ClosureAsyncSequence<[String]> { index in
            switch index {
            case 0:
                return results1
            case 1:
                waitingSignaler.yield()
                await Task { await gateStream.first { @Sendable _ in true } }.value
                return staleResults
            default:
                // the live query asks for the next value only after handling the stale one
                handledSignaler.yield()
                return nil
            }
        }

        let resultUpdates2 = ClosureAsyncSequence<[String]> { index in
            return index == 0 ? results2 : nil
        }
        resultUpdatesProducer.resultUpdatesStub = Stub(
            defaultReturnValue: resultUpdates2,
            returnValueQueue: [resultUpdates1],
        )

        let liveQuery = LiveQuery(resultUpdatesProducer: resultUpdatesProducer)

        liveQuery.queryFragment = randomAlphanumericString()
        _ = await Observations({ liveQuery.results }).first { @Sendable in $0 == results1 }
        await waitingStream.first { @Sendable _ in true }

        // exercise the test by changing the query fragment, then letting the first sequence produce a stale value
        liveQuery.queryFragment = randomAlphanumericString()
        _ = await Observations({ liveQuery.results }).first { @Sendable in $0 == results2 }

        gateSignaler.yield()
        await handledStream.first { @Sendable _ in true }

        // expect the stale value was ignored
        #expect(liveQuery.results == results2)
        #expect(liveQuery.lastError == nil)
    }


    @MainActor @Test
    mutating func errorFromResultUpdatesSetsLastErrorUntilNextFragmentProducesResults() async throws {
        // set up the test by creating a mock result updates producer that returns two streams
        let resultUpdatesProducer = StreamResultUpdatesProducer()
        resultUpdatesProducer.schedulingStrategyStub = Stub(defaultReturnValue: .passthrough)

        let canonicalFragment1 = randomAlphanumericString()
        let canonicalFragment2 = randomAlphanumericString()
        resultUpdatesProducer.canonicalQueryFragmentStub = Stub(
            defaultReturnValue: canonicalFragment2,
            returnValueQueue: [canonicalFragment1],
        )

        let (resultUpdates1, resultUpdatesContinuation1) = AsyncThrowingStream<[String], any Error>.makeStream()
        let (resultUpdates2, resultUpdatesContinuation2) = AsyncThrowingStream<[String], any Error>.makeStream()
        resultUpdatesProducer.resultUpdatesStub = Stub(
            defaultReturnValue: resultUpdates2,
            returnValueQueue: [resultUpdates1],
        )

        let liveQuery = LiveQuery(resultUpdatesProducer: resultUpdatesProducer)

        let results1 = [randomAlphanumericString()]
        liveQuery.queryFragment = randomAlphanumericString()
        resultUpdatesContinuation1.yield(results1)
        _ = await Observations({ liveQuery.results }).first { @Sendable in $0 == results1 }

        // exercise the test by making the first stream throw an error
        let expectedError = randomError()
        resultUpdatesContinuation1.finish(throwing: expectedError)
        _ = await Observations({ liveQuery.lastError != nil }).first { @Sendable in $0 }

        // expect the error is captured and the results are preserved
        #expect(liveQuery.results == results1)
        #expect(liveQuery.lastError as? ArbitraryError == expectedError)

        // exercise the test by changing the query fragment and producing results
        let results2 = [randomAlphanumericString()]
        liveQuery.queryFragment = randomAlphanumericString()
        resultUpdatesContinuation2.yield(results2)
        _ = await Observations({ liveQuery.results }).first { @Sendable in $0 == results2 }

        // expect the error is cleared
        #expect(liveQuery.lastError == nil)
    }


    @MainActor @Test
    mutating func cancellationOfSupersededResultUpdatesIsNotReportedAsError() async throws {
        // set up the test by creating a mock result updates producer whose first sequence throws when cancelled
        let resultUpdatesProducer = ClosureResultUpdatesProducer()
        resultUpdatesProducer.schedulingStrategyStub = Stub(defaultReturnValue: .passthrough)
        resultUpdatesProducer.canonicalQueryFragmentStub = Stub(
            defaultReturnValue: randomAlphanumericString(),
            returnValueQueue: [randomAlphanumericString()],
        )

        let results1 = [randomAlphanumericString()]
        let results2 = [randomAlphanumericString()]

        let (waitingStream, waitingSignaler) = AsyncStream<Void>.makeStream()
        let (cancellationStream, cancellationSignaler) = AsyncStream<Void>.makeStream()
        let resultUpdates1 = ClosureAsyncSequence<[String]> { index in
            guard index > 0 else {
                return results1
            }

            defer {
                cancellationSignaler.yield()
            }

            waitingSignaler.yield()
            try await Task.sleep(for: .seconds(3600))
            return nil
        }

        let resultUpdates2 = ClosureAsyncSequence<[String]> { index in
            return index == 0 ? results2 : nil
        }
        resultUpdatesProducer.resultUpdatesStub = Stub(
            defaultReturnValue: resultUpdates2,
            returnValueQueue: [resultUpdates1],
        )

        let liveQuery = LiveQuery(resultUpdatesProducer: resultUpdatesProducer)

        liveQuery.queryFragment = randomAlphanumericString()
        _ = await Observations({ liveQuery.results }).first { @Sendable in $0 == results1 }
        await waitingStream.first { @Sendable _ in true }

        // exercise the test by changing the query fragment
        liveQuery.queryFragment = randomAlphanumericString()
        await cancellationStream.first { @Sendable _ in true }
        _ = await Observations({ liveQuery.results }).first { @Sendable in $0 == results2 }

        // expect the cancellation wasn’t reported as an error
        #expect(liveQuery.lastError == nil)
    }


    @MainActor @Test
    mutating func supersededResultsProducerCallIsCancelledAndItsResultsAreIgnored() async throws {
        // set up the test by creating a mock results producer whose first call waits for a gate, ignoring
        // cancellation, and then reports whether it was cancelled
        let resultsProducer = MockLiveQueryResultsProducer<[String]>()
        resultsProducer.schedulingStrategyStub = Stub(defaultReturnValue: .passthrough)

        let canonicalFragment1 = randomAlphanumericString()
        let canonicalFragment2 = randomAlphanumericString()
        resultsProducer.canonicalQueryFragmentStub = Stub(
            defaultReturnValue: canonicalFragment2,
            returnValueQueue: [canonicalFragment1],
        )

        // the second call reaches the stub first, so it gets the queued results
        let results1 = [randomAlphanumericString()]
        let results2 = [randomAlphanumericString()]
        resultsProducer.resultsStub = ThrowingStub(
            defaultReturnValue: results1,
            resultQueue: [.success(results2)],
        )

        let callCounter = CallCounter()
        let (waitingStream, waitingSignaler) = AsyncStream<Void>.makeStream()
        let (gateStream, gateSignaler) = AsyncStream<Void>.makeStream()
        let (cancellationStream, cancellationSignaler) = AsyncStream<Bool>.makeStream()
        resultsProducer.resultsPrologue = {
            guard callCounter.increment() == 0 else {
                return
            }

            waitingSignaler.yield()
            await Task { await gateStream.first { @Sendable _ in true } }.value
            cancellationSignaler.yield(Task.isCancelled)
        }

        let (epilogueStream, epilogueSignaler) = AsyncStream<Void>.makeStream()
        resultsProducer.resultsEpilogue = {
            epilogueSignaler.yield()
        }

        let liveQuery = LiveQuery(resultsProducer: resultsProducer)

        liveQuery.queryFragment = randomAlphanumericString()
        await waitingStream.first { @Sendable _ in true }

        // exercise the test by changing the query fragment while the first call is running
        liveQuery.queryFragment = randomAlphanumericString()
        _ = await Observations({ liveQuery.results }).first { @Sendable in $0 == results2 }

        // let the first call finish
        gateSignaler.yield()
        let wasCancelled = await cancellationStream.first { @Sendable _ in true }
        for await _ in epilogueStream.prefix(2) {}

        // expect the first call was cancelled and its results were ignored
        #expect(wasCancelled == true)
        #expect(resultsProducer.resultsStub.callArguments == [canonicalFragment2, canonicalFragment1])
        #expect(liveQuery.results == results2)
        #expect(liveQuery.lastError == nil)
    }


    @MainActor @Test
    mutating func releasingLiveQueryCancelsResultUpdates() async throws {
        // set up the test by creating a mock result updates producer whose sequence waits for a gate, ignoring
        // cancellation, and then reports whether it was cancelled
        let resultUpdatesProducer = ClosureResultUpdatesProducer()
        resultUpdatesProducer.schedulingStrategyStub = Stub(defaultReturnValue: .passthrough)
        resultUpdatesProducer.canonicalQueryFragmentStub = Stub(defaultReturnValue: randomAlphanumericString())

        let results1 = [randomAlphanumericString()]
        let results2 = [randomAlphanumericString()]

        let (waitingStream, waitingSignaler) = AsyncStream<Void>.makeStream()
        let (gateStream, gateSignaler) = AsyncStream<Void>.makeStream()
        let (cancellationStream, cancellationSignaler) = AsyncStream<Bool>.makeStream()
        resultUpdatesProducer.resultUpdatesStub = Stub(
            defaultReturnValue: ClosureAsyncSequence<[String]> { index in
                switch index {
                case 0:
                    return results1
                case 1:
                    waitingSignaler.yield()
                    await Task { await gateStream.first { @Sendable _ in true } }.value
                    cancellationSignaler.yield(Task.isCancelled)
                    return results2
                default:
                    return nil
                }
            }
        )

        weak var weakLiveQuery: LiveQuery<[String]>?
        do {
            let liveQuery = LiveQuery(resultUpdatesProducer: resultUpdatesProducer)
            weakLiveQuery = liveQuery

            liveQuery.queryFragment = randomAlphanumericString()
            _ = await Observations({ liveQuery.results }).first { @Sendable in $0 == results1 }
            await waitingStream.first { @Sendable _ in true }
        }

        // exercise the test by releasing the live query, then letting the sequence continue
        #expect(weakLiveQuery == nil)
        gateSignaler.yield()

        // expect the sequence’s iteration was cancelled
        let wasCancelled = await cancellationStream.first { @Sendable _ in true }
        #expect(wasCancelled == true)
    }
}


/// A mock result updates producer whose result updates are async throwing streams.
private typealias StreamResultUpdatesProducer = MockLiveQueryResultUpdatesProducer<
    [String], AsyncThrowingStream<[String], any Error>
>


/// A mock result updates producer whose result updates are closure async sequences.
private typealias ClosureResultUpdatesProducer = MockLiveQueryResultUpdatesProducer<
    [String], ClosureAsyncSequence<[String]>
>


/// A thread-safe counter that tests use to tell calls apart.
private final class CallCounter: Sendable {
    /// A mutex that synchronizes access to the count.
    private let count = Mutex(0)


    /// Increments the count, returning its value before the increment.
    func increment() -> Int {
        return count.withLock { count in
            defer {
                count += 1
            }

            return count
        }
    }
}
