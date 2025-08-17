//
//  MockRetryPolicy.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/17/25.
//

import DevFoundation
import DevTesting
import Foundation

final class MockRetryPolicy<Input, Output>: HashableByID, RetryPolicy {
    struct RetryDelayArguments {
        let input: Input
        let output: Output
        let attemptCount: Int
        let previousDelay: Duration?
    }


    nonisolated(unsafe) var retryDelayStub: Stub<RetryDelayArguments, Duration?>!


    func retryDelay(
        forInput input: Input,
        output: Output,
        attemptCount: Int,
        previousDelay: Duration?
    ) -> Duration? {
        retryDelayStub(
            .init(
                input: input,
                output: output,
                attemptCount: attemptCount,
                previousDelay: previousDelay
            )
        )
    }
}
