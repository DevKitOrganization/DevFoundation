//
//  TopLevelCodingTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/19/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing


struct TopLevelCodingTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func decodeTopLevelKeyThrowsWhenDecodingFails() {
        let decoder = JSONDecoder()

        #expect(throws: DecodingError.self) {
            try decoder.decode(Int.self, from: randomData(), topLevelKey: MockCodable.CodingKeys.int)
        }

        #expect(decoder.userInfo[.init(rawValue: "DevFoundation.topLevelKeyToDecode")!] == nil)
    }


    @Test
    mutating func decodeTopLevelKeyReturnsCorrectValue() throws {
        let expectedString = randomBasicLatinString()
        let mockCodable = MockCodable(
            array: [],
            bool: randomBool(),
            int: random(Int.self, in: .min ... .max),
            string: expectedString
        )

        let encodedData = try PropertyListEncoder().encode(mockCodable)
        let decoder = PropertyListDecoder()
        let actualString = try decoder.decode(
            String.self,
            from: encodedData,
            topLevelKey: MockCodable.CodingKeys.string
        )
        #expect(actualString == expectedString)

        #expect(decoder.userInfo[.init(rawValue: "DevFoundation.topLevelKeyToDecode")!] == nil)
    }
}
