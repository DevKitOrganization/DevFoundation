//
//  AnyRequestConditionTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/31/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct AnyRequestConditionTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initSetsBase() {
        let mockCondition = MockRequestCondition()
        let anyCondition = SimulatedURLRequestLoader.RequestConditions.AnyRequestCondition(mockCondition)

        #expect(anyCondition.base as? MockRequestCondition === mockCondition)
    }


    @Test(arguments: [false, true])
    mutating func isFulfilledDelegatesToBase(isFulfilled: Bool) {
        let mockCondition = MockRequestCondition()
        mockCondition.isFulfilledStub = Stub(defaultReturnValue: isFulfilled)
        let anyCondition = SimulatedURLRequestLoader.RequestConditions.AnyRequestCondition(mockCondition)

        let requestComponents = SimulatedURLRequestLoader.RequestComponents(urlRequest: randomURLRequest())!

        #expect(anyCondition.isFulfilled(by: requestComponents) == isFulfilled)
        #expect(mockCondition.isFulfilledStub.callArguments == [requestComponents])
    }


    @Test
    mutating func descriptionReturnsBaseDescription() {
        let mockCondition = MockRequestCondition()
        let expectedDescription = randomAlphanumericString()
        mockCondition.descriptionStub = Stub(defaultReturnValue: expectedDescription)
        let anyCondition = SimulatedURLRequestLoader.RequestConditions.AnyRequestCondition(mockCondition)

        #expect(String(describing: anyCondition) == expectedDescription)
        #expect(mockCondition.descriptionStub.calls.count == 1)
    }
}
