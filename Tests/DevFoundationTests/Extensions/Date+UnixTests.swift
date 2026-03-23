//
//  Date+UnixTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/23/26.
//

import DevFoundation
import DevTesting
import Foundation
import RealModule
import Testing

struct Date_UnixTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initWithSecondsSince1970SetsCorrectDate() {
        for _ in 0 ..< 100 {
            // set up
            let seconds = random(Int64.self, in: -4_000_000 ... 4_000_000)

            // exercise
            let date = Date(secondsSince1970: seconds)

            // expect
            #expect(date.timeIntervalSince1970 == TimeInterval(seconds))
        }
    }


    @Test
    mutating func initWithMillisecondsSince1970AsInt64SetsCorrectDate() {
        for _ in 0 ..< 100 {
            // set up
            let milliseconds = random(Int64.self, in: -4_000_000 ... 4_000_000)

            // exercise
            let date = Date(millisecondsSince1970: milliseconds)

            // expect
            #expect(
                date.timeIntervalSince1970.isApproximatelyEqual(
                    to: Float64(milliseconds) / 1000,
                    absoluteTolerance: 0.0001
                )
            )
        }
    }


    @Test
    mutating func initWithMillisecondsSince1970AsFloat64SetsCorrectDate() {
        for _ in 0 ..< 100 {
            // set up
            let milliseconds = randomFloat64(in: -4_000_000 ..< 4_000_000)

            // exercise
            let date = Date(millisecondsSince1970: milliseconds)

            // expect
            #expect(
                date.timeIntervalSince1970.isApproximatelyEqual(
                    to: milliseconds / 1000,
                    absoluteTolerance: 0.0001
                )
            )
        }
    }


    @Test
    mutating func secondsSince1970ReturnsCorrectValue() {
        for _ in 0 ..< 100 {
            // set up
            let date = randomDate()

            // expect
            #expect(date.secondsSince1970 == Int64(date.timeIntervalSince1970))
        }
    }


    @Test
    mutating func millisecondsSince1970ReturnsCorrectValue() {
        for _ in 0 ..< 100 {
            // set up
            let date = randomDate()

            // expect
            #expect(date.millisecondsSince1970 == Int64(date.timeIntervalSince1970 * 1000))
        }
    }
}
