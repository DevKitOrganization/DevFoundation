//
//  HTTPMethodTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/13/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing


struct HTTPMethodTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initSetsRawValueUppercased() {
        let rawValue = randomAlphanumericString()

        let httpMethod = HTTPMethod(rawValue)
        #expect(httpMethod.rawValue == rawValue.uppercased())
    }


    @Test
    func constantValues() {
        #expect(HTTPMethod.delete.rawValue == "DELETE")
        #expect(HTTPMethod.get.rawValue == "GET")
        #expect(HTTPMethod.patch.rawValue == "PATCH")
        #expect(HTTPMethod.post.rawValue == "POST")
        #expect(HTTPMethod.put.rawValue == "PUT")
    }
}
