//
//  BodyEqualsTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/31/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct BodyEqualsTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initSetsBody() {
        let body = randomData()
        let condition = SimulatedURLRequestLoader.RequestConditions.BodyEquals(body: body)

        #expect(condition.body == body)
    }


    @Test
    mutating func isFulfilledReturnsTrueWhenBodyMatches() {
        let body = randomData()
        let condition = SimulatedURLRequestLoader.RequestConditions.BodyEquals(body: body)

        var urlRequest = randomURLRequest()
        urlRequest.httpBody = body
        let requestComponents = SimulatedURLRequestLoader.RequestComponents(urlRequest: urlRequest)!

        #expect(condition.isFulfilled(by: requestComponents))
    }


    @Test
    mutating func isFulfilledReturnsFalseWhenBodyDoesNotMatch() {
        let body = randomData()
        let condition = SimulatedURLRequestLoader.RequestConditions.BodyEquals(body: body)

        var urlRequest = randomURLRequest()
        urlRequest.httpBody = randomData()
        let requestComponents = SimulatedURLRequestLoader.RequestComponents(urlRequest: urlRequest)!

        #expect(!condition.isFulfilled(by: requestComponents))
    }


    @Test
    mutating func isFulfilledReturnsFalseWhenRequestHasNoBody() {
        let body = randomData()
        let condition = SimulatedURLRequestLoader.RequestConditions.BodyEquals(body: body)

        let urlRequest = randomURLRequest()
        let requestComponents = SimulatedURLRequestLoader.RequestComponents(urlRequest: urlRequest)!

        #expect(!condition.isFulfilled(by: requestComponents))
    }


    @Test
    mutating func descriptionReturnsExpectedFormat() {
        let body = randomData()
        let condition = SimulatedURLRequestLoader.RequestConditions.BodyEquals(body: body)

        #expect(String(describing: condition) == ".bodyEquals(\(body))")
    }


    @Test
    mutating func bodyEqualsCreatesConditionWithSpecifiedBody() {
        let body = randomData()
        let condition: SimulatedURLRequestLoader.RequestConditions.BodyEquals = .bodyEquals(body)

        #expect(condition.body == body)
    }
}
