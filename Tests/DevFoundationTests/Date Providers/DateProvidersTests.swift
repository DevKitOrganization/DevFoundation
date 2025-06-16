//
//  DateProvidersTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 6/16/25.
//

@testable import DevFoundation
import DevTesting
import Foundation
import Testing


@Suite(.serialized)
struct DateProvidersTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func currentIsSetCorrectly() {
        let mockDateProvider = MockDateProvider()

        let dateProvider = DateProviders.current
        #expect(dateProvider is SystemDateProvider)

        DateProviders.current = mockDateProvider
        #expect(DateProviders.current as? MockDateProvider === mockDateProvider)

        DateProviders.current = DateProviders.system
        #expect(dateProvider is SystemDateProvider)
    }


    @Test
    mutating func autoupdatingCurrentTracksCurrent() {
        let autoupdatingCurrent = DateProviders.autoupdatingCurrent
        #expect(autoupdatingCurrent.now.isApproximatelyEqual(to: DateProviders.current.now, absoluteTolerance: 0.01))

        let mockNow = randomDate()
        let mockDateProvider = MockDateProvider(now: mockNow)
        DateProviders.current = mockDateProvider
        #expect(DateProviders.autoupdatingCurrent.now == mockNow)
    }
}
