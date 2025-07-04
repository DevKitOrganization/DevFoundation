//
//  InvalidWebServiceRequestErrorTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/18/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct InvalidWebServiceRequestErrorTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initSetsProperties() {
        let debugDescription = randomBasicLatinString()

        for underlyingError in [nil, randomError()] {
            let error = InvalidWebServiceRequestError(
                debugDescription: debugDescription,
                underlyingError: underlyingError
            )
            #expect(error.debugDescription == debugDescription)
            #expect(error.underlyingError as? MockError == underlyingError)
        }
    }
}
