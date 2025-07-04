//
//  DateProvidersTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 6/16/25.
//

import DevTesting
import Foundation
import Testing

@testable import DevFoundation

@Suite(.serialized)
struct DateProvidersTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func currentIsSetCorrectly() {
        let dateProvider = DateProviders.current
        #expect(dateProvider is SystemDateProvider)

        DateProviders.current = TestSystemDateProvider()
        #expect(DateProviders.current is TestSystemDateProvider)

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
        DateProviders.current = DateProviders.system
    }
}


private struct TestSystemDateProvider: DateProvider {
    var now: Date {
        return Date()
    }
}
