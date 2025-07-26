//
//  IdentifiableBySelfTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 7/26/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct IdentifiableBySelfTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func identifiableConformance() {
        let value = MockIdentifiableBySelf(
            bool: randomBool(),
            int: random(Int.self, in: .min ... .max),
            float64: random(Float64.self, in: -10_000 ... 10_000),
            string: randomAlphanumericString()
        )

        #expect(value.id == value)
    }
}


private struct MockIdentifiableBySelf: IdentifiableBySelf {
    let bool: Bool
    let int: Int
    let float64: Float64
    let string: String
}
