//
//  BodyEqualsDecodableTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/31/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct BodyEqualsDecodableTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initSetsBodyAndDecoder() {
        let body = randomBody()
        let decoder = JSONDecoder()
        let condition = SimulatedURLRequestLoader.RequestConditions.BodyEqualsDecodable(body: body, decoder: decoder)

        #expect(condition.body == body)
        #expect(condition.decoder === decoder)
    }


    @Test
    mutating func isFulfilledReturnsTrueWhenDecodedBodyMatches() throws {
        let body = randomBody()
        let decoder = PropertyListDecoder()
        let condition = SimulatedURLRequestLoader.RequestConditions.BodyEqualsDecodable(body: body, decoder: decoder)

        let encodedData = try PropertyListEncoder().encode(body)
        var urlRequest = randomURLRequest()
        urlRequest.httpBody = encodedData
        let requestComponents = SimulatedURLRequestLoader.RequestComponents(urlRequest: urlRequest)!

        #expect(condition.isFulfilled(by: requestComponents))
    }


    @Test
    mutating func isFulfilledReturnsFalseWhenDecodedBodyDoesNotMatch() throws {
        let body = randomBody()
        let decoder = JSONDecoder()
        let condition = SimulatedURLRequestLoader.RequestConditions.BodyEqualsDecodable(body: body, decoder: decoder)

        let differentBody = TestCodable(id: randomInt(in: .min ... .max), name: randomAlphanumericString())
        let encodedData = try JSONEncoder().encode(differentBody)
        var urlRequest = randomURLRequest()
        urlRequest.httpBody = encodedData
        let requestComponents = SimulatedURLRequestLoader.RequestComponents(urlRequest: urlRequest)!

        #expect(!condition.isFulfilled(by: requestComponents))
    }


    @Test
    mutating func isFulfilledReturnsFalseWhenRequestBodyCannotBeDecoded() {
        let body = randomBody()
        let decoder = PropertyListDecoder()
        let condition = SimulatedURLRequestLoader.RequestConditions.BodyEqualsDecodable(body: body, decoder: decoder)

        var urlRequest = randomURLRequest()
        urlRequest.httpBody = randomData()
        let requestComponents = SimulatedURLRequestLoader.RequestComponents(urlRequest: urlRequest)!

        #expect(!condition.isFulfilled(by: requestComponents))
    }


    @Test
    mutating func isFulfilledReturnsFalseWhenRequestHasNoBody() {
        let body = randomBody()
        let decoder = JSONDecoder()
        let condition = SimulatedURLRequestLoader.RequestConditions.BodyEqualsDecodable(body: body, decoder: decoder)

        let urlRequest = randomURLRequest()
        let requestComponents = SimulatedURLRequestLoader.RequestComponents(urlRequest: urlRequest)!

        #expect(!condition.isFulfilled(by: requestComponents))
    }


    @Test
    mutating func descriptionReturnsExpectedFormat() {
        let body = randomBody()
        let decoder = JSONDecoder()
        let condition = SimulatedURLRequestLoader.RequestConditions.BodyEqualsDecodable(body: body, decoder: decoder)

        #expect(String(describing: condition) == ".bodyEquals(\(body), decoder: \(decoder))")
    }


    @Test
    mutating func bodyEqualsCreatesConditionWithSpecifiedBodyAndDefaultDecoder() throws {
        let body = randomBody()
        let condition: SimulatedURLRequestLoader.RequestConditions.AnyRequestCondition = .bodyEquals(body)

        let typedCondition = try #require(
            condition.base as? SimulatedURLRequestLoader.RequestConditions.BodyEqualsDecodable<TestCodable>
        )
        #expect(typedCondition.body == body)
        #expect(typedCondition.decoder is JSONDecoder)
    }


    @Test
    mutating func bodyEqualsCreatesConditionWithSpecifiedBodyAndDecoder() throws {
        let body = randomBody()
        let decoder = PropertyListDecoder()
        let condition: SimulatedURLRequestLoader.RequestConditions.AnyRequestCondition = .bodyEquals(
            body,
            decoder: decoder
        )

        let typedCondition = try #require(
            condition.base as? SimulatedURLRequestLoader.RequestConditions.BodyEqualsDecodable<TestCodable>
        )
        #expect(typedCondition.body == body)
        #expect(typedCondition.decoder === decoder)
    }


    private mutating func randomBody() -> TestCodable {
        return TestCodable(
            id: randomInt(in: .min ... .max),
            name: randomAlphanumericString()
        )
    }
}


struct TestCodable: Codable, Equatable, Sendable {
    let id: Int
    let name: String
}
