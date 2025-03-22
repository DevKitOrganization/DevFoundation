//
//  HTTPBodyTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/13/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing


struct HTTPBodyTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initSetsValues() {
        let contentType = randomMediaType()
        let data = randomData()

        let body = HTTPBody(contentType: contentType, data: data)
        #expect(body.contentType == contentType)
        #expect(body.data == data)
    }
}
