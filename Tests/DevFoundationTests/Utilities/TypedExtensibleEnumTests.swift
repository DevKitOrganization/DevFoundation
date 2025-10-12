//
//  TypedExtensibleEnumTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/13/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct TypedExtensibleEnumTests: RandomValueGenerating {
    var randomNumberGenerator = Self.makeRandomNumberGenerator()


    @Test
    mutating func testInitWithRawValue() {
        let rawValue = randomBasicLatinString()
        let typedExtensibleEnum = MockTypedExtensibleEnum<String>(rawValue: rawValue)
        #expect(typedExtensibleEnum.rawValue == rawValue)
    }
}


private struct MockTypedExtensibleEnum<RawValue>: TypedExtensibleEnum where RawValue: Hashable & Sendable {
    let rawValue: RawValue


    init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}
