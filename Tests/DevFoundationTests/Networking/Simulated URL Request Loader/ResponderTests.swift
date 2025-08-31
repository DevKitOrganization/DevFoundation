//
//  ResponderTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/31/25.
//

import DevTesting
import Foundation
import Testing

@testable import DevFoundation

struct ResponderTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test(arguments: [false, true])
    mutating func initSetsProperties(hasMax: Bool) {
        let requestConditions = Array(count: randomInt(in: 3 ... 5)) { MockRequestCondition() }
        let responseGenerator = MockResponseGenerator()
        let maxResponses = hasMax ? randomInt(in: 2 ... 5) : nil

        let responder = SimulatedURLRequestLoader.Responder(
            requestConditions: requestConditions,
            responseGenerator: responseGenerator,
            maxResponses: maxResponses
        )

        #expect(responder.requestConditions as? [MockRequestCondition] == requestConditions)
        #expect(responder.responseGenerator as? MockResponseGenerator === responseGenerator)
        #expect(responder.maxResponses == maxResponses)
    }


    @Test(arguments: [false, true])
    mutating func isFulfilledInitiallyFalse(hasMax: Bool) {
        let requestConditions = Array(count: randomInt(in: 3 ... 5)) { MockRequestCondition() }
        let responseGenerator = MockResponseGenerator()
        let maxResponses = hasMax ? randomInt(in: 2 ... 5) : nil

        let responder = SimulatedURLRequestLoader.Responder(
            requestConditions: requestConditions,
            responseGenerator: responseGenerator,
            maxResponses: maxResponses
        )

        #expect(!responder.isFulfilled)
    }


    @Test
    mutating func isFulfilledTrueAfterMaxResponsesReached() async throws {
        let requestConditions = Array(count: randomInt(in: 3 ... 5)) {
            randomMockRequestCondition(isFulfilled: true)
        }
        let responseGenerator = MockResponseGenerator()
        responseGenerator.responseStub = Stub(
            defaultReturnValue: (.success((randomData(), randomHTTPURLResponse())), delay: .zero)
        )
        let maxResponses = randomInt(in: 2 ... 3)

        let responder = SimulatedURLRequestLoader.Responder(
            requestConditions: requestConditions,
            responseGenerator: responseGenerator,
            maxResponses: maxResponses
        )

        let requestComponents = try #require(
            SimulatedURLRequestLoader.RequestComponents(urlRequest: randomURLRequest()))

        // Respond maxResponses times
        for _ in 0 ..< maxResponses {
            _ = try await responder.respond(to: requestComponents)
        }

        #expect(responder.isFulfilled)
    }


    @Test
    mutating func isFulfilledTrueWithNilMaxResponsesAfterOneResponse() async throws {
        let requestConditions = Array(count: randomInt(in: 3 ... 5)) {
            randomMockRequestCondition(isFulfilled: true)
        }
        let responseGenerator = MockResponseGenerator()
        responseGenerator.responseStub = Stub(
            defaultReturnValue: (.success((randomData(), randomHTTPURLResponse())), delay: .zero)
        )

        let responder = SimulatedURLRequestLoader.Responder(
            requestConditions: requestConditions,
            responseGenerator: responseGenerator,
            maxResponses: nil
        )

        let requestComponents = try #require(
            SimulatedURLRequestLoader.RequestComponents(urlRequest: randomURLRequest())
        )

        _ = try await responder.respond(to: requestComponents)

        #expect(responder.isFulfilled)
    }


    @Test
    mutating func respondReturnsNilWhenConditionsNotMet() async throws {
        let requestConditions = Array(count: randomInt(in: 3 ... 5)) {
            randomMockRequestCondition(isFulfilled: false)
        }
        let responseGenerator = MockResponseGenerator()
        responseGenerator.responseStub = Stub(
            defaultReturnValue: (.success((randomData(), randomHTTPURLResponse())), delay: .zero)
        )

        let responder = SimulatedURLRequestLoader.Responder(
            requestConditions: requestConditions,
            responseGenerator: responseGenerator,
            maxResponses: randomInt(in: 2 ... 5)
        )

        let requestComponents = try #require(
            SimulatedURLRequestLoader.RequestComponents(urlRequest: randomURLRequest())
        )

        #expect(try await responder.respond(to: requestComponents) == nil)
    }


    @Test
    mutating func respondReturnsNilWhenAlreadyFulfilled() async throws {
        let requestConditions = Array(count: randomInt(in: 3 ... 5)) {
            randomMockRequestCondition(isFulfilled: true)
        }
        let responseGenerator = MockResponseGenerator()
        responseGenerator.responseStub = Stub(
            defaultReturnValue: (.success((randomData(), randomHTTPURLResponse())), delay: .zero)
        )

        let responder = SimulatedURLRequestLoader.Responder(
            requestConditions: requestConditions,
            responseGenerator: responseGenerator,
            maxResponses: 0
        )

        let requestComponents = try #require(
            SimulatedURLRequestLoader.RequestComponents(urlRequest: randomURLRequest())
        )

        #expect(responder.isFulfilled)
        #expect(try await responder.respond(to: requestComponents) == nil)
    }


    @Test
    mutating func respondReturnsResponseWhenConditionsMetAndNotFulfilled() async throws {
        let requestConditions = Array(count: randomInt(in: 3 ... 5)) {
            randomMockRequestCondition(isFulfilled: true)
        }
        let responseGenerator = MockResponseGenerator()
        let expectedData = randomData()
        let expectedResponse = randomHTTPURLResponse()
        responseGenerator.responseStub = Stub(
            defaultReturnValue: (.success((expectedData, expectedResponse)), delay: .zero)
        )

        let responder = SimulatedURLRequestLoader.Responder(
            requestConditions: requestConditions,
            responseGenerator: responseGenerator,
            maxResponses: randomInt(in: 2 ... 5)
        )

        let requestComponents = try #require(
            SimulatedURLRequestLoader.RequestComponents(urlRequest: randomURLRequest())
        )

        let result = try await responder.respond(to: requestComponents)
        let (actualData, actualResponse) = try #require(result)

        #expect(actualData == expectedData)
        #expect(actualResponse === expectedResponse)
    }


    @Test
    mutating func respondIncrementsResponseCountCorrectly() async throws {
        let requestConditions = Array(count: randomInt(in: 3 ... 5)) {
            randomMockRequestCondition(isFulfilled: true)
        }
        let responseGenerator = MockResponseGenerator()
        responseGenerator.responseStub = Stub(
            defaultReturnValue: (.success((randomData(), randomHTTPURLResponse())), delay: .zero)
        )
        let maxResponses = 3

        let responder = SimulatedURLRequestLoader.Responder(
            requestConditions: requestConditions,
            responseGenerator: responseGenerator,
            maxResponses: maxResponses
        )

        let requestComponents = try #require(
            SimulatedURLRequestLoader.RequestComponents(urlRequest: randomURLRequest())
        )

        #expect(!responder.isFulfilled)

        // Response 1
        let result1 = try await responder.respond(to: requestComponents)
        #expect(result1 != nil)
        #expect(!responder.isFulfilled)

        // Response 2
        let result2 = try await responder.respond(to: requestComponents)
        #expect(result2 != nil)
        #expect(!responder.isFulfilled)

        // Response 3 - should fulfill the responder
        let result3 = try await responder.respond(to: requestComponents)
        #expect(result3 != nil)
        #expect(responder.isFulfilled)

        // Response 4 should return nil
        let result4 = try await responder.respond(to: requestComponents)
        #expect(result4 == nil)
    }


    @Test
    mutating func respondSleepsForSpecifiedDelay() async throws {
        let requestConditions = Array(count: randomInt(in: 3 ... 5)) {
            randomMockRequestCondition(isFulfilled: true)
        }
        let responseGenerator = MockResponseGenerator()
        let delay = Duration.milliseconds(100)
        responseGenerator.responseStub = Stub(
            defaultReturnValue: (.success((randomData(), randomHTTPURLResponse())), delay: delay)
        )

        let responder = SimulatedURLRequestLoader.Responder(
            requestConditions: requestConditions,
            responseGenerator: responseGenerator,
            maxResponses: randomInt(in: 2 ... 5)
        )

        let requestComponents = try #require(
            SimulatedURLRequestLoader.RequestComponents(urlRequest: randomURLRequest())
        )

        let startTime = ContinuousClock().now
        _ = try await responder.respond(to: requestComponents)
        let endTime = ContinuousClock().now
        let elapsedTime = endTime - startTime

        #expect(elapsedTime >= delay)
    }


    @Test
    mutating func respondReturnsFalseWhenShouldRespondChangesDuringResponse() async throws {
        let requestConditions = Array(count: randomInt(in: 3 ... 5)) {
            randomMockRequestCondition(isFulfilled: true)
        }
        let responseGenerator = MockResponseGenerator()
        responseGenerator.responseStub = Stub(
            defaultReturnValue: (.success((randomData(), randomHTTPURLResponse())), delay: .zero)
        )

        let responder = SimulatedURLRequestLoader.Responder(
            requestConditions: requestConditions,
            responseGenerator: responseGenerator,
            maxResponses: 1
        )

        let requestComponents = try #require(
            SimulatedURLRequestLoader.RequestComponents(urlRequest: randomURLRequest())
        )

        // Set up prologue to sleep, allowing the responder to be fulfilled by another call
        responseGenerator.responsePrologue = {
            try? await Task.sleep(for: .milliseconds(250))
        }

        // Start two concurrent responses
        async let result1 = responder.respond(to: requestComponents)
        async let result2 = responder.respond(to: requestComponents)

        let (response1, response2) = try await (result1, result2)

        // One should succeed, one should return nil due to maxResponses = 1
        let successCount = [response1, response2].compactMap { $0 }.count
        #expect(successCount == 1)
        #expect(responder.isFulfilled)
    }


    private mutating func randomMockRequestCondition(isFulfilled: Bool) -> MockRequestCondition {
        let condition = MockRequestCondition()
        condition.isFulfilledStub = Stub(defaultReturnValue: isFulfilled)
        condition.descriptionStub = Stub(defaultReturnValue: randomAlphanumericString())
        return condition
    }
}
