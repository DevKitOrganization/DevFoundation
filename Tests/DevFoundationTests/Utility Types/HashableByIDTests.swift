//
//  HashableByIDTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/16/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct HashableByIDTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func hashableConformance() {
        let equalID = random(Int.self, in: -100 ..< 100)

        let equal1 = MockHashableByID(
            id: equalID,
            irrelevantBool: randomBool(),
            irrelevantInt: random(Int.self, in: .min ... .max),
            irrelevantString: randomBasicLatinString()
        )

        let equal2 = MockHashableByID(
            id: equalID,
            irrelevantBool: randomBool(),
            irrelevantInt: random(Int.self, in: .min ... .max),
            irrelevantString: randomBasicLatinString()
        )

        let unequal = MockHashableByID(
            id: equalID + 1,
            irrelevantBool: randomBool(),
            irrelevantInt: random(Int.self, in: .min ... .max),
            irrelevantString: randomBasicLatinString()
        )

        #expect(equal1 == equal2)
        #expect(equal1.hashValue == equal2.hashValue)
        #expect(unequal != equal1)
        #expect(unequal != equal2)

        let set: Set<MockHashableByID> = [equal1]
        #expect(set.contains(equal2))
        #expect(!set.contains(unequal))
    }
}


private struct MockHashableByID: HashableByID {
    let id: Int
    let irrelevantBool: Bool
    let irrelevantInt: Int
    let irrelevantString: String
}
