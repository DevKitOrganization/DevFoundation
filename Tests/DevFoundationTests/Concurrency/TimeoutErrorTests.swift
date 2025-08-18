//
//  TimeoutErrorTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/18/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct TimeoutErrorTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initSetsTimeout() {
        let timeout = randomDuration()
        let error = TimeoutError(timeout: timeout)

        #expect(error.timeout == timeout)
    }


    @Test
    mutating func customStringConvertible() {
        let timeout = randomDuration()
        let error = TimeoutError(timeout: timeout)

        #expect(String(describing: error) == "Operation timed out after \(timeout)")
    }
}
