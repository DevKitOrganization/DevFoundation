//
//  AnySendableHashableTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 4/1/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct AnySendableHashableTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func testPropertiesAndHashable() {
        let base = randomBasicLatinString()
        let anySendableHashable = AnySendableHashable(base)

        #expect(base == anySendableHashable.base as? String)
        #expect(anySendableHashable.hashValue == base.hashValue)
    }
}
