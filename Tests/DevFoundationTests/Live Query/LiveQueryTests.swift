//
//  LiveQueryTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 10/24/2025.
//

import DevTesting
import Foundation
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
        await signalStream.first { _ in true }

        // expect canonicalQueryFragment was called twice with correct arguments
        #expect(resultsProducer.canonicalQueryFragmentStub.callArguments == [fragment1, fragment2])

        // expect the results producer was called only once with the canonical fragment
        #expect(resultsProducer.resultsStub.callArguments == [canonicalFragment])
    }


    // MARK: - results

    @Test
    mutating func settingValidQueryFragmentProducesResults() async throws {
        // set up the test by creating a mock results producer
        let resultsProducer = MockLiveQueryResultsProducer<[String]>()
        resultsProducer.schedulingStrategyStub = Stub(defaultReturnValue: .passthrough)

        let queryFragment = randomAlphanumericString()
        resultsProducer.canonicalQueryFragmentStub = Stub(defaultReturnValue: queryFragment)

        let expectedResults = [randomAlphanumericString(), randomAlphanumericString()]
        resultsProducer.resultsStub = ThrowingStub(defaultReturnValue: expectedResults)

        let (signalStream, signaler) = AsyncStream<Void>.makeStream()
        resultsProducer.resultsEpilogue = {
            signaler.yield()
        }

        let liveQuery = LiveQuery(resultsProducer: resultsProducer)

        // exercise the test by setting a valid query fragment
        liveQuery.queryFragment = queryFragment

        // wait for results to be produced
        await signalStream.first { _ in true }

        // expect the results match what the producer returned
        #expect(liveQuery.results == expectedResults)
        #expect(resultsProducer.resultsStub.callArguments == [queryFragment])
    }


    // MARK: - lastError

    @Test
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
            returnValueQueue: [canonicalFragment1]
        )

        let initialResults = [randomAlphanumericString()]
        let expectedError = randomError()
        resultsProducer.resultsStub = ThrowingStub(
            defaultError: expectedError,
            resultQueue: [.success(initialResults)]
        )

        let (signalStream, signaler) = AsyncStream<Void>.makeStream()
        resultsProducer.resultsEpilogue = {
            signaler.yield()
        }

        let liveQuery = LiveQuery(resultsProducer: resultsProducer)

        // exercise the test by first producing successful results
        liveQuery.queryFragment = fragment1
        await signalStream.first { _ in true }

        #expect(liveQuery.results == initialResults)
        #expect(liveQuery.lastError == nil)

        // exercise the test by producing an error
        liveQuery.queryFragment = fragment2
        await signalStream.first { _ in true }

        // expect the error is captured and previous results are preserved
        #expect(liveQuery.results == initialResults)
        #expect(liveQuery.lastError as? MockError == expectedError)
    }


    @Test
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
            returnValueQueue: [canonicalFragment1]
        )

        let expectedError = randomError()
        let newResults = [randomAlphanumericString()]
        resultsProducer.resultsStub = ThrowingStub(
            defaultReturnValue: newResults,
            resultQueue: [.failure(expectedError)]
        )

        let (signalStream, signaler) = AsyncStream<Void>.makeStream()
        resultsProducer.resultsEpilogue = {
            signaler.yield()
        }

        let liveQuery = LiveQuery(resultsProducer: resultsProducer)

        // exercise the test by first producing an error
        liveQuery.queryFragment = fragment1
        await signalStream.first { _ in true }

        #expect(liveQuery.results == nil)
        #expect(liveQuery.lastError as? MockError == expectedError)

        // exercise the test by producing successful results
        liveQuery.queryFragment = fragment2
        await signalStream.first { _ in true }

        // expect the error is cleared
        #expect(liveQuery.results == newResults)
        #expect(liveQuery.lastError == nil)
    }


    // MARK: - Scheduling Strategies

    @Test
    mutating func passthroughStrategyProducesResultsForAllFragments() async throws {
        // set up the test by creating a mock results producer with passthrough strategy
        let resultsProducer = MockLiveQueryResultsProducer<[String]>()
        resultsProducer.schedulingStrategyStub = Stub(defaultReturnValue: .passthrough)

        let canonicalFragment1 = randomAlphanumericString()
        let canonicalFragment2 = randomAlphanumericString()
        let canonicalFragment3 = randomAlphanumericString()
        resultsProducer.canonicalQueryFragmentStub = Stub(
            defaultReturnValue: canonicalFragment3,
            returnValueQueue: [canonicalFragment1, canonicalFragment2]
        )

        let results1 = [randomAlphanumericString()]
        let results2 = [randomAlphanumericString()]
        let results3 = [randomAlphanumericString()]
        resultsProducer.resultsStub = ThrowingStub(
            defaultReturnValue: results3,
            resultQueue: [.success(results1), .success(results2)]
        )

        let (signalStream, signaler) = AsyncStream<Void>.makeStream()
        resultsProducer.resultsEpilogue = {
            signaler.yield()
        }

        let liveQuery = LiveQuery(resultsProducer: resultsProducer)

        // exercise the test by setting multiple query fragments
        liveQuery.queryFragment = randomAlphanumericString()
        liveQuery.queryFragment = randomAlphanumericString()
        liveQuery.queryFragment = randomAlphanumericString()

        // wait for all three results to be produced
        for try await _ in signalStream.prefix(3) {}

        // expect all three results were produced
        #expect(
            resultsProducer.resultsStub.callArguments == [canonicalFragment1, canonicalFragment2, canonicalFragment3]
        )
        #expect(liveQuery.results == results3)
    }


    @Test
    mutating func debounceStrategyDelaysResultProduction() async throws {
        // set up the test by creating a mock results producer with debounce strategy
        let resultsProducer = MockLiveQueryResultsProducer<[String]>()
        let debounceDuration = Duration.milliseconds(200)
        resultsProducer.schedulingStrategyStub = Stub(defaultReturnValue: .debounce(debounceDuration))

        let canonicalFragment = randomAlphanumericString()
        resultsProducer.canonicalQueryFragmentStub = Stub(defaultReturnValue: canonicalFragment)

        let expectedResults = [randomAlphanumericString()]
        resultsProducer.resultsStub = ThrowingStub(defaultReturnValue: expectedResults)

        let (signalStream, signaler) = AsyncStream<Void>.makeStream()
        resultsProducer.resultsEpilogue = {
            signaler.yield()
        }

        let liveQuery = LiveQuery(resultsProducer: resultsProducer)

        // exercise the test by setting a query fragment
        liveQuery.queryFragment = randomAlphanumericString()

        // expect results are not immediately available
        try await Task.sleep(for: .milliseconds(50))
        #expect(liveQuery.results == nil)
        #expect(resultsProducer.resultsStub.callArguments.isEmpty)

        // wait for debounce to complete
        await signalStream.first { _ in true }

        // expect results are now available
        #expect(liveQuery.results == expectedResults)
        #expect(resultsProducer.resultsStub.callArguments == [canonicalFragment])
    }
}
