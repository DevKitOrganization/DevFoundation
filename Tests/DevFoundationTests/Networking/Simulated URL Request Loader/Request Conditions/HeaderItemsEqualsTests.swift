//
//  HeaderItemsEqualsTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/31/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct HeaderItemsEqualsTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initSetsHeaderItems() {
        let headerItems = Set(count: randomInt(in: 2 ... 4)) { randomHTTPHeaderItem() }
        let condition = SimulatedURLRequestLoader.RequestConditions.HeaderItemsEquals(headerItems: headerItems)

        #expect(condition.headerItems == headerItems)
    }


    @Test
    mutating func isFulfilledReturnsTrueWhenHeaderItemsMatch() {
        let headerItems = Set(count: randomInt(in: 2 ... 4)) { randomHTTPHeaderItem() }
        let condition = SimulatedURLRequestLoader.RequestConditions.HeaderItemsEquals(headerItems: headerItems)

        var urlRequest = randomURLRequest()
        urlRequest.httpHeaderItems = Array(headerItems)
        let requestComponents = SimulatedURLRequestLoader.RequestComponents(urlRequest: urlRequest)!

        #expect(condition.isFulfilled(by: requestComponents))
    }


    @Test
    mutating func isFulfilledReturnsFalseWhenHeaderItemsDoNotMatch() {
        let headerItems = Set(count: randomInt(in: 2 ... 4)) { randomHTTPHeaderItem() }
        let condition = SimulatedURLRequestLoader.RequestConditions.HeaderItemsEquals(headerItems: headerItems)

        var urlRequest = randomURLRequest()
        var modifiedHeaderItems = headerItems
        modifiedHeaderItems.insert(randomHTTPHeaderItem())
        urlRequest.httpHeaderItems = Array(modifiedHeaderItems)
        let requestComponents = SimulatedURLRequestLoader.RequestComponents(urlRequest: urlRequest)!

        #expect(!condition.isFulfilled(by: requestComponents))
    }


    @Test
    mutating func descriptionReturnsExpectedFormat() {
        let headerItems = Set(count: randomInt(in: 2 ... 4)) { randomHTTPHeaderItem() }
        let condition = SimulatedURLRequestLoader.RequestConditions.HeaderItemsEquals(headerItems: headerItems)

        #expect(String(describing: condition) == ".headerItemsEquals(\(headerItems))")
    }


    @Test
    mutating func headerItemsEqualsCreatesConditionWithSpecifiedHeaderItems() {
        let headerItems = Set(count: randomInt(in: 2 ... 4)) { randomHTTPHeaderItem() }
        let condition: SimulatedURLRequestLoader.RequestConditions.HeaderItemsEquals = .headerItemsEquals(
            headerItems
        )

        #expect(condition.headerItems == headerItems)
    }
}
