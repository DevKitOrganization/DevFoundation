//
//  PathMatchesTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/31/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct PathMatchesTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initSetsPathRegexAndPercentEncoded() {
        let pattern = /[a-z]+/
        let percentEncoded = randomBool()

        let condition = SimulatedURLRequestLoader.RequestConditions.PathMatches(
            pattern: pattern,
            percentEncoded: percentEncoded
        )

        #expect(condition.percentEncoded == percentEncoded)
    }


    @Test
    mutating func isFulfilledReturnsTrueWhenPathMatches() {
        let condition = SimulatedURLRequestLoader.RequestConditions.PathMatches(
            pattern: #//users/[0-9]+/#,
            percentEncoded: false
        )
        let urlRequest = URLRequest(url: URL(string: "https://api.example.com/users/123")!)
        let requestComponents = SimulatedURLRequestLoader.RequestComponents(urlRequest: urlRequest)!

        #expect(condition.isFulfilled(by: requestComponents))
    }


    @Test
    mutating func isFulfilledReturnsFalseWhenPathDoesNotMatch() {
        let condition = SimulatedURLRequestLoader.RequestConditions.PathMatches(
            pattern: #//users/[0-9]+/#,
            percentEncoded: false
        )
        let urlRequest = URLRequest(url: URL(string: "https://api.example.com/posts/abc")!)
        let requestComponents = SimulatedURLRequestLoader.RequestComponents(urlRequest: urlRequest)!

        #expect(!condition.isFulfilled(by: requestComponents))
    }


    @Test
    mutating func descriptionReturnsExpectedFormat() {
        let pattern = #//users/[0-9]+/#
        let condition = SimulatedURLRequestLoader.RequestConditions.PathMatches(
            pattern: pattern,
            percentEncoded: true
        )

        #expect(String(describing: condition) == ".pathMatches(*****, percentEncoded: true)")
    }


    @Test
    mutating func pathEqualsCreatesConditionWithVerbatimRegex() {
        let path = "/users/123"
        let condition: SimulatedURLRequestLoader.RequestConditions.PathMatches = .pathEquals(
            path,
            percentEncoded: false
        )

        #expect(condition.percentEncoded == false)

        let urlRequest = URLRequest(url: URL(string: "https://api.example.com/users/123")!)
        let requestComponents = SimulatedURLRequestLoader.RequestComponents(urlRequest: urlRequest)!

        #expect(condition.isFulfilled(by: requestComponents))
    }


    @Test
    mutating func pathMatchesCreatesConditionWithCustomRegex() {
        let pathPattern = #/.*api/v[0-9]+/users/#
        let condition: SimulatedURLRequestLoader.RequestConditions.PathMatches = .pathMatches(
            pathPattern,
            percentEncoded: true
        )

        #expect(condition.percentEncoded == true)

        let urlRequest = URLRequest(url: URL(string: "https://api.example.com/api/v2/users")!)
        let requestComponents = SimulatedURLRequestLoader.RequestComponents(urlRequest: urlRequest)!

        #expect(condition.isFulfilled(by: requestComponents))
    }
}
