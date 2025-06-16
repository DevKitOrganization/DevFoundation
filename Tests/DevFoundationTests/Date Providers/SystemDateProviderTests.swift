//
//  SystemDateProviderTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 6/16/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing


struct SystemDateProviderTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func nowIsCorrect() {
        let systemDateProvider = DateProviders.system

        for _ in 0 ..< 100 {
            #expect(systemDateProvider.now.isApproximatelyEqual(to: Date(), absoluteTolerance: 0.01))
        }
    }


    @Test
    func descriptionIsCorrect() {
        #expect(String(describing: DateProviders.system) == "DateProviders.system")
    }
}
