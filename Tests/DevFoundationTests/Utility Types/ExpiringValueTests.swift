//
//  ExpiringValueTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 6/16/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct ExpiringValueTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func memberwiseInitSetsValuesCorrectly() {
        let value = randomAlphanumericString()
        let start = randomDate()
        let end = start + random(TimeInterval.self, in: 1 ... 10_000)

        let expiringValue = ExpiringValue(value, lifetimeRange: start ... end)
        #expect(expiringValue.value == value)
        #expect(expiringValue.lifetimeRange == start ... end)
    }


    @Test
    mutating func durationInitSetsValuesCorrectly() {
        let value = randomUUID()
        let duration = random(TimeInterval.self, in: 1 ... 10_000)

        let date = Date()
        let expiringValue = ExpiringValue(value, lifetimeDuration: duration)

        #expect(expiringValue.value == value)
        #expect(expiringValue.lifetimeRange.lowerBound.isApproximatelyEqual(to: date, absoluteTolerance: 0.01))
        #expect(
            expiringValue.lifetimeRange.upperBound.isApproximatelyEqual(to: date + duration, absoluteTolerance: 0.01)
        )
    }


    @Test
    mutating func expireMarksValueAsExpired() {
        var expiringValue = ExpiringValue(
            random(Int.self, in: .min ... .max),
            lifetimeRange: .distantPast ... .distantFuture
        )

        expiringValue.expire()
        #expect(expiringValue.isExpired)
        #expect(expiringValue.isExpired(at: .distantPast))
        #expect(expiringValue.isExpired(at: .distantFuture))
    }


    @Test
    mutating func isExpiredReturnsCorrectValues() {
        let interval = random(TimeInterval.self, in: 10_000 ... 50_000)
        let start = Date(timeIntervalSinceNow: -interval)
        let end = Date(timeIntervalSinceNow: interval)

        let expiringValue = ExpiringValue(
            random(UInt.self, in: 0 ... .max),
            lifetimeRange: start ... end
        )

        #expect(!expiringValue.isExpired)

        #expect(!expiringValue.isExpired(at: start))
        #expect(!expiringValue.isExpired(at: end))

        #expect(expiringValue.isExpired(at: start - 0.01))
        #expect(expiringValue.isExpired(at: end + 0.01))
    }
}
