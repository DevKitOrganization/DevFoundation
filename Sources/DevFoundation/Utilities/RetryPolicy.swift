//
//  RetryPolicy.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/16/25.
//

import Foundation

/// A type that can determine whether an operation should be retried.
///
/// ``HTTPClient`` uses a retry policy to automatically retry requests, but retry policies can be applied to other use
/// cases as well. See ``PredefinedDelaySequenceRetryPolicy`` and ``AggregateRetryPolicy`` for concrete policies that
/// are included with DevFoundation.
public protocol RetryPolicy<Input, Output>: Sendable {
    /// The success type of the operation to which the policy applies.
    associatedtype Input

    /// The failure type of the operation to which the policy applies.
    associatedtype Output


    /// Returns the amount of time that should elapse before an operation is retried.
    ///
    /// Conforming types should inspect `input`, `output`, `attemptCount`, and `previousDelay` to determine if a retry
    /// should be attempted, and if so, how long to delay retrying.
    ///
    /// - Parameters:
    ///   - input: The input to the operation.
    ///   - output: The output of the operation.
    ///   - attemptCount: The number of times the operation has run (including the first one).
    ///   - previousDelay: The previous delay that was returned by the retry policy for this operation. `nil` means that
    ///     no previous attempt was made.
    /// - Returns: The amount of time that should elapse before retrying. Return `nil` to indicate that no retry should
    ///   occur. The returned duration should not be negative.
    func retryDelay(
        forInput input: Input,
        output: Output,
        attemptCount: Int,
        previousDelay: Duration?
    ) -> Duration?
}


/// A retry policy whose delays come from a predefined sequence.
///
/// `PredefinedDelaySequenceRetryPolicy` uses a closure to determine whether a retry should occur, and uses an array to
/// return the delay duration long. By carefully setting `delays` and `maxRetries`, you can express a wide variety of
/// useful policies.
public struct PredefinedDelaySequenceRetryPolicy<Input, Output>: RetryPolicy {
    /// The delay durations to use for each successive retry.
    ///
    /// If empty, a delay of `.zero` is used.
    public var delays: [Duration]

    /// The maximum number of retries before the policy stops retrying.
    ///
    /// If less than 1, no retries occur.
    public var maxRetries: Int

    /// A closure that returns whether a retry should occur.
    public var retryPredicate: @Sendable (Input, Output) -> Bool


    /// Creates a new predefined delay sequence retry policy with the specified delays, max attempts, and retry
    /// predicate.
    ///
    /// - Parameters:
    ///   - delays: The delay durations to use for each successive retry.
    ///   - maxRetries: The maximum number of retries before the policy stops retrying. If `nil`, `maxRetries` is set to
    ///     `delays.count`. `nil` by default.
    ///   - retryPredicate: A closure that returns whether a retry should occur.
    public init(
        delays: [Duration],
        maxRetries: Int? = nil,
        retryPredicate: @escaping @Sendable (Input, Output) -> Bool
    ) {
        self.delays = delays
        self.maxRetries = maxRetries ?? delays.count
        self.retryPredicate = retryPredicate
    }


    public func retryDelay(
        forInput input: Input,
        output: Output,
        attemptCount: Int,
        previousDelay: Duration?
    ) -> Duration? {
        guard attemptCount <= maxRetries, retryPredicate(input, output) else {
            return nil
        }

        return delays.isEmpty ? .zero : delays[min(attemptCount, delays.count) - 1]
    }
}


/// A retry policy that aggregates other retry policies.
///
/// Aggregate retry policies store an array of child policies that are used to make policy decisions. When asked for a
/// retry delay, the aggregate policy simply asks each of its child policies for a retry delay and returns the first
/// non-`nil` value. If no child policies return a delay, no retry occurs.
public struct AggregateRetryPolicy<Input, Output>: RetryPolicy {
    /// The aggregate policy’s child policies.
    public let policies: [any RetryPolicy<Input, Output>]


    /// Creates a new aggregate retry policy with the specified children.
    ///
    /// - Parameter policies: The child policies that the new policy uses to make decisions.
    public init(policies: [any RetryPolicy<Input, Output>]) {
        self.policies = policies
    }


    public func retryDelay(
        forInput input: Input,
        output: Output,
        attemptCount: Int,
        previousDelay: Duration?
    ) -> Duration? {
        for policy in policies {
            if let delay = policy.retryDelay(
                forInput: input,
                output: output,
                attemptCount: attemptCount,
                previousDelay: previousDelay
            ) {
                return delay
            }
        }

        return nil
    }
}
