//
//  OffsetDateProviderTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 6/16/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct OffsetDateProviderTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func nowIsOffsetCorrectly() {
        let date = randomDate()
        let offset = random(TimeInterval.self, in: -1000 ... 1000)

        let base = MockDateProvider(now: date)
        let offsetProvider = base.offset(by: offset)
        #expect(offsetProvider.now == base.now.addingTimeInterval(offset))
    }


    @Test
    mutating func descriptionIsCorrect() {
        let base = MockDateProvider()
        let offset = random(TimeInterval.self, in: -1000 ... 1000)
        let offsetProvider = base.offset(by: offset)

        #expect(String(describing: offsetProvider) == "\(String(describing: base)).offset(by: \(offset))")
    }
}
