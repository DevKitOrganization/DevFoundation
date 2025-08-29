//
//  WithTimeoutTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/18/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct WithTimeoutTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func operationCompletesBeforeTimeout() async throws {
        let expectedResult = randomAlphanumericString()

        let result = try await withTimeout(.milliseconds(500)) {
            try await Task.sleep(for: .milliseconds(150))
            return expectedResult
        }

        #expect(result == expectedResult)
    }


    @Test
    mutating func operationTimesOut() async throws {
        let timeout = Duration.milliseconds(500)
        let result = randomInt(in: .min ... .max)

        await #expect(throws: TimeoutError(timeout: timeout)) {
            _ = try await withTimeout(timeout) {
                try await Task.sleep(for: .milliseconds(1000))
                return result
            }
        }
    }


    @Test
    mutating func operationErrorPropagates() async throws {
        let expectedError = randomError()

        await #expect(throws: expectedError) {
            try await withTimeout(.seconds(1)) {
                throw expectedError
            }
        }
    }


    @Test
    mutating func nonThrowingOperation() async throws {
        let expectedResult = randomAlphanumericString()

        let result = try await withTimeout(.milliseconds(150)) {
            return expectedResult
        }

        #expect(result == expectedResult)
    }


    @Test
    func operationIsCancelledOnTimeout() async throws {
        _ = await confirmation { (operationStarted) in
            await confirmation(expectedCount: 0) { (operationFinished) in
                await #expect(throws: TimeoutError.self) {
                    try await withTimeout(.milliseconds(10)) {
                        operationStarted()
                        try await Task.sleep(for: .seconds(1))
                        operationFinished()
                    }
                }
            }
        }
    }
}
