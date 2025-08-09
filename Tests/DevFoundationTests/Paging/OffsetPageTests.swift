//
//  OffsetPageTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/9/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct OffsetPageTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func nextPageOffsetIsCorrect() {
        for _ in 0 ..< 10 {
            let mockPage = MockOffsetPage()
            let offset = randomInt(in: .min ..< .max)
            mockPage.pageOffsetStub = Stub(defaultReturnValue: offset)
            #expect(mockPage.nextPageOffset == offset + 1)
        }
    }
}
