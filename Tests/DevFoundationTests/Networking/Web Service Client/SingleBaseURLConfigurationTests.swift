//
//  SingleBaseURLConfigurationTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/18/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct SingleBaseURLConfigurationTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initSetsProperties() {
        let baseURL = randomURL(includeFragment: false, includeQueryItems: false)
        let configuration = SingleBaseURLConfiguration(baseURL: baseURL)
        #expect(configuration.baseURL == baseURL)
    }


    @Test
    mutating func urlForReturnsBaseURL() {
        let baseURL = randomURL(includeFragment: false, includeQueryItems: false)
        let configuration = SingleBaseURLConfiguration(baseURL: baseURL)
        #expect(configuration.url(for: ()) == baseURL)
    }
}
