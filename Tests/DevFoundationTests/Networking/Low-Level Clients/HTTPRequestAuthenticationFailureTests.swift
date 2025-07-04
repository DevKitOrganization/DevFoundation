//
//  HTTPRequestAuthenticationFailureTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/16/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct HTTPRequestAuthenticationFailureTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initSetsProperties() {
        let preparedRequest = randomURLRequest()
        let response = randomHTTPResponse()
        let error = randomError()

        let failure = HTTPRequestAuthenticationFailure(
            preparedRequest: preparedRequest,
            response: response,
            error: error
        )

        #expect(failure.preparedRequest == preparedRequest)
        #expect(failure.response == response)
        #expect(failure.error as? MockError == error)
    }
}
