//
//  LiveQueryResultsProducerTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 10/24/2025.
//

import DevTesting
import Foundation
import Testing

@testable import DevFoundation

struct LiveQueryResultsProducerTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    // MARK: - canonicalQueryFragment(from:)

    @Test(
        arguments: [
            ("hello", "hello"),
            ("  hello  ", "hello"),
            ("hello world", "hello world"),
            ("  hello   world  ", "hello world"),
            ("hello\nworld", "hello world"),
            ("hello\tworld", "hello world"),
            ("  hello  \n  world  \t  test  ", "hello world test"),
            ("", nil),
            ("   ", nil),
            ("\n\t", nil),
            ("  \n  \t  ", nil),
        ]
    )
    func canonicalQueryFragment(input: String, expected: String?) {
        // set up the test by creating a results producer
        let producer = TestResultsProducer()

        // exercise the test by canonicalizing the query fragment
        let result = producer.canonicalQueryFragment(from: input)

        // expect the result matches the expected canonical form
        #expect(result == expected)
    }


    // MARK: - resultUpdates(forQueryFragment:)

    @Test
    mutating func resultUpdatesProducesResultsOnce() async throws {
        // set up the test by creating a results producer that returns random results
        let resultsProducer = MockLiveQueryResultsProducer<[String]>()
        let results = Array(count: randomInt(in: 1 ... 5)) { randomAlphanumericString() }
        resultsProducer.resultsStub = ThrowingStub(defaultReturnValue: results)
        let queryFragment = randomAlphanumericString()

        // exercise the test by collecting the result updates
        var resultUpdates: [[String]] = []
        for try await update in resultsProducer.resultUpdates(forQueryFragment: queryFragment) {
            resultUpdates.append(update)
        }

        // expect the sequence produced the results once
        #expect(resultUpdates == [results])
        #expect(resultsProducer.resultsStub.callArguments == [queryFragment])
    }


    @Test
    mutating func resultUpdatesThrowsResultsProducerError() async throws {
        // set up the test by creating a results producer that throws an error
        let resultsProducer = MockLiveQueryResultsProducer<[String]>()
        let error = randomError()
        resultsProducer.resultsStub = ThrowingStub(defaultError: error)
        let queryFragment = randomAlphanumericString()

        // exercise the test by iterating the result updates
        let resultUpdates = resultsProducer.resultUpdates(forQueryFragment: queryFragment)

        // expect the sequence throws the results producer’s error
        await #expect(throws: error) {
            for try await _ in resultUpdates {
                // Does nothing, because the sequence throws before producing a value.
            }
        }
        #expect(resultsProducer.resultsStub.callArguments == [queryFragment])
    }


    @Test
    mutating func resultUpdatesThrowsCancellationErrorWithoutProducingResultsWhenCancelled() async throws {
        // set up the test by creating a results producer
        let resultsProducer = MockLiveQueryResultsProducer<[String]>()
        resultsProducer.resultsStub = ThrowingStub(defaultReturnValue: [randomAlphanumericString()])
        let resultUpdates = resultsProducer.resultUpdates(forQueryFragment: randomAlphanumericString())

        // exercise the test by iterating the result updates in a cancelled task
        let task = Task {
            withUnsafeCurrentTask { $0?.cancel() }
            for try await _ in resultUpdates {
                // Does nothing, because the sequence throws before producing a value.
            }
        }

        // expect the sequence throws a cancellation error without calling the results producer
        await #expect(throws: CancellationError.self) {
            try await task.value
        }
        #expect(resultsProducer.resultsStub.calls.isEmpty)
    }


    // MARK: - Test Types

    struct TestResultsProducer: LiveQueryResultsProducer {
        var schedulingStrategy: LiveQuerySchedulingStrategy {
            .passthrough
        }


        func results(forQueryFragment queryFragment: String) async throws -> [String] {
            []
        }
    }
}
