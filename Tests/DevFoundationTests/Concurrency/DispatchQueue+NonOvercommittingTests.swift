//
//  DispatchQueue+NonOvercommittingTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 4/1/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing


struct DispatchQueue_NonOvercommittingTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func testMakeNonOvercommitting() {
        let label = randomAlphanumericString()
        let qos: DispatchQoS = randomElement(
            in: [
                .background,
                .default,
                .unspecified,
                .userInitiated,
                .userInteractive,
                .utility,
            ]
        )!

        // This is all we can test really.
        let queue = DispatchQueue.makeNonOvercommitting(label: label, qos: qos)
        #expect(queue.label == label)
        #expect(queue.qos == qos)
    }
}
