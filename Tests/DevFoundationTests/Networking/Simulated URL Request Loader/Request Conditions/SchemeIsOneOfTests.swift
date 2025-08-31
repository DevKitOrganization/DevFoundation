//
//  SchemeIsOneOfTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/31/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct SchemeIsOneOfTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initSetsSchemes() {
        let schemes = Set(count: randomInt(in: 3 ... 5)) { randomScheme() }
        let condition = SimulatedURLRequestLoader.RequestConditions.SchemeIsOneOf(schemes: schemes)

        #expect(condition.schemes == schemes)
    }


    @Test
    mutating func isFulfilledReturnsTrueWhenSchemeMatches() {
        let schemes = Set(count: randomInt(in: 3 ... 5)) { randomScheme() }
        let condition = SimulatedURLRequestLoader.RequestConditions.SchemeIsOneOf(schemes: schemes)

        var urlComponents = randomURLComponents()
        urlComponents.scheme = randomElement(in: schemes)!
        let urlRequest = URLRequest(url: urlComponents.url!)
        let requestComponents = SimulatedURLRequestLoader.RequestComponents(urlRequest: urlRequest)!

        #expect(condition.isFulfilled(by: requestComponents))
    }


    @Test
    mutating func isFulfilledReturnsFalseWhenSchemeDoesNotMatch() {
        let schemes = Set(count: randomInt(in: 3 ... 5)) { randomScheme() }
        let condition = SimulatedURLRequestLoader.RequestConditions.SchemeIsOneOf(schemes: schemes)

        let urlRequest = randomURLRequest()
        let requestComponents = SimulatedURLRequestLoader.RequestComponents(urlRequest: urlRequest)!

        #expect(!condition.isFulfilled(by: requestComponents))
    }


    @Test
    mutating func descriptionReturnsExpectedFormat() {
        let schemes = Set(count: randomInt(in: 3 ... 5)) { randomScheme() }
        let condition = SimulatedURLRequestLoader.RequestConditions.SchemeIsOneOf(schemes: schemes)

        #expect(String(describing: condition) == ".scheme(isOneOf: \(schemes))")
    }


    @Test
    mutating func schemeEqualsCreatesConditionWithSingleScheme() {
        let scheme = randomScheme()
        let condition: SimulatedURLRequestLoader.RequestConditions.SchemeIsOneOf = .schemeEquals(scheme)

        #expect(condition.schemes == [scheme])
    }


    @Test
    mutating func schemeIsOneOfCreatesConditionWithMultipleSchemes() {
        let schemes = Set(count: randomInt(in: 3 ... 5)) { randomScheme() }
        let condition: SimulatedURLRequestLoader.RequestConditions.SchemeIsOneOf = .scheme(isOneOf: schemes)

        #expect(condition.schemes == schemes)
    }


    private mutating func randomScheme() -> String {
        return randomString(withCharactersFrom: "abcdefghijklmopqrstuvwxyz")
    }
}
