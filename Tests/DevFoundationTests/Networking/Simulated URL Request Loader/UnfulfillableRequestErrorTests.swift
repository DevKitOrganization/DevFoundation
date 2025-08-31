//
//  UnfulfillableRequestErrorTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/31/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct UnfulfillableRequestErrorTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initSetsRequest() {
        let urlRequest = randomURLRequest()
        let error = SimulatedURLRequestLoader.UnfulfillableRequestError(request: urlRequest)

        #expect(error.request == urlRequest)
    }
}
