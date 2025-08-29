//
//  ScaledDateProviderTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 6/16/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct ScaledDateProviderTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    #if os(macOS)
    @Test
    mutating func fatalErrorWhenScaleIsZero() async {
        await #expect(processExitsWith: .failure) {
            _ = MockDateProvider(now: Date()).scalingRate(by: 0)
        }
    }


    @Test
    mutating func fatalErrorWhenScaleIsNegative() async {
        await #expect(processExitsWith: .failure) {
            _ = MockDateProvider(now: Date()).scalingRate(by: -1)
        }
    }
    #endif


    @Test
    mutating func nowIsScaledCorrectly() {
        let baseStartDate = randomDate()
        let base = MockDateProvider(now: baseStartDate)

        let scale = random(Float64.self, in: 0.1 ... 5)
        let scaledProvider = base.scalingRate(by: scale)

        // Move the base clock forward
        let elapsedTimeInterval = randomFloat64(in: 0.01 ... 1000)
        let baseNextDate = baseStartDate + elapsedTimeInterval
        base.nowStub = Stub(defaultReturnValue: baseNextDate)

        #expect(
            scaledProvider.now.isApproximatelyEqual(
                to: baseStartDate.addingTimeInterval(elapsedTimeInterval * scale),
                absoluteTolerance: 0.01
            )
        )
    }


    @Test
    mutating func descriptionIsCorrect() {
        let base = MockDateProvider(now: randomDate())
        let scale = random(TimeInterval.self, in: 0.01 ... 1000)
        let offsetProvider = base.scalingRate(by: scale)

        #expect(String(describing: offsetProvider) == "\(String(describing: base)).scalingRate(by: \(scale))")
    }
}
