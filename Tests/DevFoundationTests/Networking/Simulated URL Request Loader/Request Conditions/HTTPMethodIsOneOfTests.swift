//
//  HTTPMethodIsOneOfTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/31/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct HTTPMethodIsOneOfTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initSetsHttpMethods() {
        let httpMethods: Set<HTTPMethod> = [.get, .post, .put]
        let condition = SimulatedURLRequestLoader.RequestConditions.HTTPMethodIsOneOf(httpMethods: httpMethods)

        #expect(condition.httpMethods == httpMethods)
    }


    @Test
    mutating func isFulfilledReturnsTrueWhenMethodMatches() {
        let condition = SimulatedURLRequestLoader.RequestConditions.HTTPMethodIsOneOf(httpMethods: [.get, .post])
        var urlRequest = randomURLRequest()
        urlRequest.httpMethod = HTTPMethod.post.rawValue
        let requestComponents = SimulatedURLRequestLoader.RequestComponents(urlRequest: urlRequest)!

        #expect(condition.isFulfilled(by: requestComponents))
    }


    @Test
    mutating func isFulfilledReturnsFalseWhenMethodDoesNotMatch() {
        let condition = SimulatedURLRequestLoader.RequestConditions.HTTPMethodIsOneOf(httpMethods: [.get, .post])
        var urlRequest = randomURLRequest()
        urlRequest.httpMethod = HTTPMethod.delete.rawValue
        let requestComponents = SimulatedURLRequestLoader.RequestComponents(urlRequest: urlRequest)!

        #expect(!condition.isFulfilled(by: requestComponents))
    }


    @Test
    mutating func descriptionReturnsExpectedFormat() {
        let httpMethods: Set<HTTPMethod> = [.get, .post]
        let condition = SimulatedURLRequestLoader.RequestConditions.HTTPMethodIsOneOf(httpMethods: httpMethods)
        #expect(String(describing: condition) == ".httpMethod(isOneOf: \(httpMethods.map(\.rawValue)))")
    }


    @Test
    mutating func httpMethodEqualsCreatesConditionWithSingleMethod() {
        let condition: SimulatedURLRequestLoader.RequestConditions.HTTPMethodIsOneOf = .httpMethodEquals(.patch)
        #expect(condition.httpMethods == [.patch])
    }


    @Test
    mutating func httpMethodIsOneOfCreatesConditionWithMultipleMethods() {
        let httpMethods: Set<HTTPMethod> = [.delete, .put, .get]
        let condition: SimulatedURLRequestLoader.RequestConditions.HTTPMethodIsOneOf = .httpMethod(
            isOneOf: httpMethods
        )

        #expect(condition.httpMethods == httpMethods)
    }
}
