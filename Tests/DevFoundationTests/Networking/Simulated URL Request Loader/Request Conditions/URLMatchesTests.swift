//
//  URLMatchesTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/31/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct URLMatchesTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func isFulfilledReturnsTrueWhenURLMatches() {
        let condition = SimulatedURLRequestLoader.RequestConditions.URLMatches(pattern: #/.*/users/[0-9]+/#)
        let urlRequest = URLRequest(url: URL(string: "https://api.example.com/users/123")!)
        let requestComponents = SimulatedURLRequestLoader.RequestComponents(urlRequest: urlRequest)!

        #expect(condition.isFulfilled(by: requestComponents))
    }


    @Test
    mutating func isFulfilledReturnsFalseWhenURLDoesNotMatch() {
        let condition = SimulatedURLRequestLoader.RequestConditions.URLMatches(pattern: #//users/[0-9]+/#)
        let urlRequest = URLRequest(url: URL(string: "https://api.example.com/posts/abc")!)
        let requestComponents = SimulatedURLRequestLoader.RequestComponents(urlRequest: urlRequest)!

        #expect(!condition.isFulfilled(by: requestComponents))
    }


    @Test
    mutating func descriptionReturnsExpectedFormat() {
        let condition = SimulatedURLRequestLoader.RequestConditions.URLMatches(pattern: #//users/[0-9]+/#)
        #expect(String(describing: condition) == ".urlMatches(*****)")
    }


    @Test
    mutating func urlEqualsCreatesConditionWithVerbatimRegex() {
        let url = URL(string: "https://api.example.com/users/123")!
        let condition: SimulatedURLRequestLoader.RequestConditions.URLMatches = .urlEquals(url)

        let urlRequest = URLRequest(url: url)
        let requestComponents = SimulatedURLRequestLoader.RequestComponents(urlRequest: urlRequest)!

        #expect(condition.isFulfilled(by: requestComponents))
    }


    @Test
    mutating func urlMatchesCreatesConditionWithCustomRegex() {
        let pattern = #/.*api/v[0-9]+/users/#
        let condition: SimulatedURLRequestLoader.RequestConditions.URLMatches = .urlMatches(pattern)

        let urlRequest = URLRequest(url: URL(string: "https://api.example.com/api/v2/users")!)
        let requestComponents = SimulatedURLRequestLoader.RequestComponents(urlRequest: urlRequest)!

        #expect(condition.isFulfilled(by: requestComponents))
    }
}
