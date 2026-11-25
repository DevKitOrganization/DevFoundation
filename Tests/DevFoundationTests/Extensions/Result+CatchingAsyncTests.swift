//
//  Result+CatchingAsyncTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/17/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct ResultCatchingAsyncTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func testResultCatchingAsyncSuccess() async {
        let expectedValue = randomAlphanumericString()

        let result = await Result<String, ArbitraryError> { () async throws(ArbitraryError) -> String in
            return expectedValue
        }

        #expect(result == .success(expectedValue))
    }


    @Test
    mutating func testResultCatchingAsyncFailure() async {
        let expectedError = randomError()

        let result = await Result<String, ArbitraryError> { () async throws(ArbitraryError) -> String in
            throw expectedError
        }

        #expect(result == .failure(expectedError))
    }
}
