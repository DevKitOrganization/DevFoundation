//
//  OptionalRepresentableTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/17/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct OptionalRepresentableTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func testOptionalRepresentationEquality() {
        for _ in 0 ..< 8 {
            let optionalValue = randomOptional(randomAlphanumericString())
            #expect(optionalValue.optionalRepresentation == optionalValue)
        }
    }
}
