//
//  HeaderItemsContainsTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/31/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct HeaderItemsContainsTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initSetsHeaderItem() {
        let headerItem = randomHTTPHeaderItem()
        let condition = SimulatedURLRequestLoader.RequestConditions.HeaderItemsContains(headerItem: headerItem)

        #expect(condition.headerItem == headerItem)
    }


    @Test
    mutating func isFulfilledReturnsTrueWhenHeaderItemIsContained() {
        let headerItem = randomHTTPHeaderItem()
        let condition = SimulatedURLRequestLoader.RequestConditions.HeaderItemsContains(headerItem: headerItem)

        var urlRequest = randomURLRequest()
        urlRequest.set(headerItem)
        urlRequest.set(randomHTTPHeaderItem())
        let requestComponents = SimulatedURLRequestLoader.RequestComponents(urlRequest: urlRequest)!

        #expect(condition.isFulfilled(by: requestComponents))
    }


    @Test
    mutating func isFulfilledReturnsFalseWhenHeaderItemIsNotContained() {
        let headerItem = randomHTTPHeaderItem()
        let condition = SimulatedURLRequestLoader.RequestConditions.HeaderItemsContains(headerItem: headerItem)

        var urlRequest = randomURLRequest()
        urlRequest.setValue(randomAlphanumericString(), forHTTPHeaderField: headerItem.field.rawValue)
        urlRequest.setValue(randomAlphanumericString(), forHTTPHeaderField: randomAlphanumericString())
        let requestComponents = SimulatedURLRequestLoader.RequestComponents(urlRequest: urlRequest)!

        #expect(!condition.isFulfilled(by: requestComponents))
    }


    @Test
    mutating func isFulfilledReturnsFalseWhenHeaderNameIsNotPresent() {
        let headerItem = randomHTTPHeaderItem()
        let condition = SimulatedURLRequestLoader.RequestConditions.HeaderItemsContains(headerItem: headerItem)

        var urlRequest = randomURLRequest()
        urlRequest.set(randomHTTPHeaderItem())
        let requestComponents = SimulatedURLRequestLoader.RequestComponents(urlRequest: urlRequest)!

        #expect(!condition.isFulfilled(by: requestComponents))
    }


    @Test
    mutating func descriptionReturnsExpectedFormat() {
        let headerItem = randomHTTPHeaderItem()
        let condition = SimulatedURLRequestLoader.RequestConditions.HeaderItemsContains(headerItem: headerItem)

        #expect(String(describing: condition) == ".headerItemsContains(\(headerItem))")
    }


    @Test
    mutating func headerItemsContainsCreatesConditionWithSpecifiedHeaderItem() {
        let headerItem = randomHTTPHeaderItem()
        let condition: SimulatedURLRequestLoader.RequestConditions.HeaderItemsContains = .headerItemsContains(
            headerItem
        )

        #expect(condition.headerItem == headerItem)
    }
}
