//
//  QueryItemsEqualsTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/31/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct QueryItemsEqualsTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initSetsQueryItems() {
        let queryItems = Array(count: randomInt(in: 2 ... 4)) { randomURLQueryItem() }
        let condition = SimulatedURLRequestLoader.RequestConditions.QueryItemsEquals(queryItems: queryItems)

        #expect(condition.queryItems == queryItems)
    }


    @Test
    mutating func isFulfilledReturnsTrueWhenQueryItemsMatch() {
        let queryItems = Array(count: randomInt(in: 2 ... 4)) { randomURLQueryItem() }
        let condition = SimulatedURLRequestLoader.RequestConditions.QueryItemsEquals(queryItems: queryItems)

        var urlComponents = randomURLComponents(includeQueryItems: false)
        urlComponents.queryItems = queryItems
        let urlRequest = URLRequest(url: urlComponents.url!)
        let requestComponents = SimulatedURLRequestLoader.RequestComponents(urlRequest: urlRequest)!

        #expect(condition.isFulfilled(by: requestComponents))
    }


    @Test
    mutating func isFulfilledReturnsFalseWhenQueryItemsDoNotMatch() {
        let queryItems = Array(count: randomInt(in: 2 ... 4)) { randomURLQueryItem() }
        let condition = SimulatedURLRequestLoader.RequestConditions.QueryItemsEquals(queryItems: queryItems)

        let urlRequest = randomURLRequest()
        let requestComponents = SimulatedURLRequestLoader.RequestComponents(urlRequest: urlRequest)!

        #expect(!condition.isFulfilled(by: requestComponents))
    }


    @Test
    mutating func descriptionReturnsExpectedFormat() {
        let queryItems = Array(count: randomInt(in: 2 ... 4)) { randomURLQueryItem() }
        let condition = SimulatedURLRequestLoader.RequestConditions.QueryItemsEquals(queryItems: queryItems)

        #expect(String(describing: condition) == ".queryItemsEquals(\(queryItems))")
    }


    @Test
    mutating func queryItemsEqualsCreatesConditionWithSpecifiedQueryItems() {
        let queryItems = Array(count: randomInt(in: 2 ... 4)) { randomURLQueryItem() }
        let condition: SimulatedURLRequestLoader.RequestConditions.QueryItemsEquals = .queryItemsEquals(queryItems)

        #expect(condition.queryItems == queryItems)
    }
}
