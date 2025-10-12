//
//  RetryPolicyTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/17/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct RetryPolicyTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func testPredefinedDelaySequenceRetryPolicyInit() {
        let delays = Array(count: randomInt(in: 2 ... 5)) {
            Duration.seconds(randomInt(in: 1 ... 10))
        }
        let maxRetries = randomInt(in: 5 ... 20)

        let policy = PredefinedDelaySequenceRetryPolicy<String, String>(
            delays: delays,
            maxRetries: maxRetries,
            retryPredicate: { _, _ in true }
        )

        #expect(policy.delays == delays)
        #expect(policy.maxRetries == maxRetries)
    }


    @Test
    mutating func testPredefinedDelaySequenceRetryPolicyInitWithDefaultMaxAttempts() {
        let delays = Array(count: randomInt(in: 2 ... 5)) {
            Duration.seconds(randomInt(in: 1 ... 10))
        }

        let policy = PredefinedDelaySequenceRetryPolicy<String, String>(
            delays: delays,
            retryPredicate: { _, _ in true }
        )

        #expect(policy.delays == delays)
        #expect(policy.maxRetries == delays.count)
    }


    @Test
    mutating func testPredefinedDelaySequenceWithEmptyDelays() {
        let policy = PredefinedDelaySequenceRetryPolicy<String, String>(
            delays: [],
            maxRetries: 1,
            retryPredicate: { _, _ in true }
        )

        let delay = policy.retryDelay(
            forInput: randomAlphanumericString(),
            output: randomAlphanumericString(),
            attemptCount: 1,
            previousDelay: nil
        )

        #expect(delay == .zero)
    }


    @Test
    mutating func testPredefinedDelaySequenceWithSingleDelay() {
        let singleDelay = Duration.seconds(randomInt(in: 1 ... 10))
        let policy = PredefinedDelaySequenceRetryPolicy<String, String>(
            delays: [singleDelay],
            maxRetries: 2,
            retryPredicate: { _, _ in true }
        )

        let delay = policy.retryDelay(
            forInput: randomAlphanumericString(),
            output: randomAlphanumericString(),
            attemptCount: 1,
            previousDelay: nil
        )

        #expect(delay == singleDelay)
    }


    @Test
    mutating func testPredefinedDelaySequenceWithMultipleDelays() {
        let delays = [Duration.seconds(1), Duration.seconds(2), Duration.seconds(4)]
        let policy = PredefinedDelaySequenceRetryPolicy<String, String>(
            delays: delays,
            maxRetries: 5,
            retryPredicate: { _, _ in true }
        )

        for (i, expected) in delays.enumerated() {
            let actual = policy.retryDelay(
                forInput: randomAlphanumericString(),
                output: randomAlphanumericString(),
                attemptCount: i + 1,
                previousDelay: i == 0 ? nil : delays[i - 1]
            )
            #expect(actual == expected)
        }
    }


    @Test
    mutating func testPredefinedDelaySequenceRetryPredicateFalse() {
        let policy = PredefinedDelaySequenceRetryPolicy<String, String>(
            delays: [Duration.seconds(1)],
            retryPredicate: { _, _ in false }
        )

        let delay = policy.retryDelay(
            forInput: randomAlphanumericString(),
            output: randomAlphanumericString(),
            attemptCount: 1,
            previousDelay: nil
        )

        #expect(delay == nil)
    }


    @Test
    mutating func testPredefinedDelaySequenceMaxAttemptsExceeded() {
        let policy = PredefinedDelaySequenceRetryPolicy<String, String>(
            delays: [Duration.seconds(1)],
            retryPredicate: { _, _ in true }
        )

        let delay = policy.retryDelay(
            forInput: randomAlphanumericString(),
            output: randomAlphanumericString(),
            attemptCount: 2,
            previousDelay: nil
        )

        #expect(delay == nil)
    }


    @Test
    mutating func testAggregateRetryPolicyInit() {
        let mockPolicy1 = MockRetryPolicy<String, String>()
        let mockPolicy2 = MockRetryPolicy<String, String>()

        let aggregatePolicy = AggregateRetryPolicy(policies: [mockPolicy1, mockPolicy2])

        #expect(aggregatePolicy.policies as? [MockRetryPolicy<String, String>] == [mockPolicy1, mockPolicy2])
    }


    @Test
    mutating func testAggregateRetryPolicyLaterPolicyReturnsDelay() throws {
        let mockPolicy1 = MockRetryPolicy<String, String>()
        mockPolicy1.retryDelayStub = Stub(defaultReturnValue: nil)

        let mockPolicy2 = MockRetryPolicy<String, String>()
        let expectedDelay = Duration.seconds(randomInt(in: 1 ... 10))
        mockPolicy2.retryDelayStub = Stub(defaultReturnValue: expectedDelay)

        let aggregatePolicy = AggregateRetryPolicy(policies: [mockPolicy1, mockPolicy2])

        let input = randomAlphanumericString()
        let output = randomAlphanumericString()
        let attemptCount = randomInt(in: 1 ... 5)
        let previousDelay = Duration.seconds(randomInt(in: 1 ... 3))

        let delay = aggregatePolicy.retryDelay(
            forInput: input,
            output: output,
            attemptCount: attemptCount,
            previousDelay: previousDelay
        )

        #expect(delay == expectedDelay)

        #expect(mockPolicy1.retryDelayStub.calls.count == 1)
        let args1 = try #require(mockPolicy1.retryDelayStub.callArguments.first)
        #expect(args1.input == input)
        #expect(args1.output == output)
        #expect(args1.attemptCount == attemptCount)
        #expect(args1.previousDelay == previousDelay)

        #expect(mockPolicy2.retryDelayStub.calls.count == 1)
        let args2 = try #require(mockPolicy2.retryDelayStub.callArguments.first)
        #expect(args2.input == input)
        #expect(args2.output == output)
        #expect(args2.attemptCount == attemptCount)
        #expect(args2.previousDelay == previousDelay)
    }


    @Test
    mutating func testAggregateRetryPolicyNoPoliciesReturnDelay() throws {
        let mockPolicy1 = MockRetryPolicy<String, String>()
        mockPolicy1.retryDelayStub = Stub(defaultReturnValue: nil)

        let mockPolicy2 = MockRetryPolicy<String, String>()
        mockPolicy2.retryDelayStub = Stub(defaultReturnValue: nil)

        let aggregatePolicy = AggregateRetryPolicy(policies: [mockPolicy1, mockPolicy2])

        let input = randomAlphanumericString()
        let output = randomAlphanumericString()
        let attemptCount = randomInt(in: 1 ... 5)
        let previousDelay = Duration.seconds(randomInt(in: 1 ... 3))

        let delay = aggregatePolicy.retryDelay(
            forInput: input,
            output: output,
            attemptCount: attemptCount,
            previousDelay: previousDelay
        )

        #expect(delay == nil)
        #expect(mockPolicy1.retryDelayStub.calls.count == 1)
        #expect(mockPolicy2.retryDelayStub.calls.count == 1)

        let args1 = try #require(mockPolicy1.retryDelayStub.callArguments.first)
        #expect(args1.input == input)
        #expect(args1.output == output)
        #expect(args1.attemptCount == attemptCount)
        #expect(args1.previousDelay == previousDelay)

        let args2 = try #require(mockPolicy2.retryDelayStub.callArguments.first)
        #expect(args2.input == input)
        #expect(args2.output == output)
        #expect(args2.attemptCount == attemptCount)
        #expect(args2.previousDelay == previousDelay)
    }
}
