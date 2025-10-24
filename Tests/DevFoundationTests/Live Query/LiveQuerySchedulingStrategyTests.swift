//
//  LiveQuerySchedulingStrategyTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 10/24/2025.
//

import DevTesting
import Foundation
import Testing

@testable import DevFoundation

struct LiveQuerySchedulingStrategyTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    func passthroughPropertyCreatesPassthroughStrategy() {
        // exercise the test by accessing the passthrough property
        let strategy = LiveQuerySchedulingStrategy.passthrough

        // expect that the strategy is passthrough
        #expect(strategy.strategy == .passthrough)
    }


    @Test
    mutating func debounceCreatesDebounceStrategyWithDuration() {
        // set up the test by generating a random duration
        let duration = Duration.milliseconds(randomInt(in: 0 ... 10_000))

        // exercise the test by creating a debounce strategy
        let strategy = LiveQuerySchedulingStrategy.debounce(duration)

        // expect that the strategy is debounce with the correct duration
        #expect(strategy.strategy == .debounce(duration))
    }
}
