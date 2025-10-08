//
//  Duration+TimeIntervalTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 10/8/25.
//

import DevFoundation
import DevTesting
import Foundation
import RealModule
import Testing

struct Duration_TimeIntervalTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func timeIntervalReturnsCorrectValue() {
        #expect(Duration.seconds(0).timeInterval == 0)
        #expect(Duration.milliseconds(-500).timeInterval == -0.5)
        #expect(Duration.milliseconds(1375).timeInterval == 1.375)

        for _ in 0 ..< 100 {
            let originalTimeInterval = random(TimeInterval.self, in: -100_000 ... 100_000)
            #expect(
                Duration
                    .seconds(originalTimeInterval).timeInterval
                    .isApproximatelyEqual(to: originalTimeInterval, absoluteTolerance: 0.001)
            )
        }
    }
}
