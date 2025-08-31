//
//  QueryItemsContainsTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/31/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct QueryItemsContainsTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initSetsQueryItem() {
        let queryItem = randomURLQueryItem()
        let condition = SimulatedURLRequestLoader.RequestConditions.QueryItemsContains(queryItem: queryItem)

        #expect(condition.queryItem == queryItem)
    }


    @Test
    mutating func isFulfilledReturnsTrueWhenQueryItemIsContained() {
        let queryItem = randomURLQueryItem()
        let condition = SimulatedURLRequestLoader.RequestConditions.QueryItemsContains(queryItem: queryItem)

        var urlComponents = randomURLComponents(includeQueryItems: false)
        urlComponents.queryItems = [queryItem, randomURLQueryItem()]
        let urlRequest = URLRequest(url: urlComponents.url!)
        let requestComponents = SimulatedURLRequestLoader.RequestComponents(urlRequest: urlRequest)!

        #expect(condition.isFulfilled(by: requestComponents))
    }


    @Test
    mutating func isFulfilledReturnsFalseWhenQueryItemIsNotContained() {
        let queryItem = randomURLQueryItem()
        let condition = SimulatedURLRequestLoader.RequestConditions.QueryItemsContains(queryItem: queryItem)

        let urlRequest = randomURLRequest()
        let requestComponents = SimulatedURLRequestLoader.RequestComponents(urlRequest: urlRequest)!

        #expect(!condition.isFulfilled(by: requestComponents))
    }


    @Test
    mutating func isFulfilledReturnsFalseWhenQueryItemsIsNil() {
        let queryItem = randomURLQueryItem()
        let condition = SimulatedURLRequestLoader.RequestConditions.QueryItemsContains(queryItem: queryItem)

        let urlComponents = randomURLComponents(includeQueryItems: false)
        let urlRequest = URLRequest(url: urlComponents.url!)
        let requestComponents = SimulatedURLRequestLoader.RequestComponents(urlRequest: urlRequest)!

        #expect(!condition.isFulfilled(by: requestComponents))
    }


    @Test
    mutating func descriptionReturnsExpectedFormat() {
        let queryItem = randomURLQueryItem()
        let condition = SimulatedURLRequestLoader.RequestConditions.QueryItemsContains(queryItem: queryItem)

        #expect(String(describing: condition) == ".queryItemsContains(\(queryItem))")
    }


    @Test
    mutating func queryItemsContainsCreatesConditionWithSpecifiedQueryItem() {
        let queryItem = randomURLQueryItem()
        let condition: SimulatedURLRequestLoader.RequestConditions.QueryItemsContains = .queryItemsContains(queryItem)

        #expect(condition.queryItem == queryItem)
    }
}
