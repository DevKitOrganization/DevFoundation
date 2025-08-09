//
//  InvalidHTTPStatusCodeErrorTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/20/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct InvalidHTTPStatusCodeErrorTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func propertiesAreCorrect() {
        let statusCode = randomInt(in: 100 ..< 600)
        let httpURLResponse = randomHTTPURLResponse(statusCode: statusCode)
        let error = InvalidHTTPStatusCodeError(httpURLResponse: httpURLResponse)
        #expect(error.httpURLResponse == httpURLResponse)
        #expect(error.statusCode == .init(statusCode))
    }
}
