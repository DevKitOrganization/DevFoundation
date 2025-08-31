//
//  ResponseGeneratorTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/31/25.
//

import DevTesting
import Foundation
import Testing

@testable import DevFoundation

struct ResponseGeneratorTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func fixedResponseGeneratorWithSuccessResultGeneratesResponse() async throws {
        let statusCode = randomHTTPStatusCode()
        let headerItems = Set(count: randomInt(in: 2 ... 4)) { randomHTTPHeaderItem() }
        let body = randomData()
        let delay = Duration.milliseconds(randomInt(in: 10 ... 100))

        let template = SimulatedURLRequestLoader.SuccessResponseTemplate(
            statusCode: statusCode,
            headerItems: headerItems,
            body: body
        )
        let generator = SimulatedURLRequestLoader.FixedResponseGenerator(
            result: .success(template),
            delay: delay
        )

        let requestComponents = try #require(
            SimulatedURLRequestLoader.RequestComponents(urlRequest: randomURLRequest())
        )

        let result = await generator.response(for: requestComponents)

        let (responseResult, responseDelay) = try #require(result)
        #expect(responseDelay == delay)

        let (responseData, urlResponse) = try responseResult.get()
        #expect(responseData == body)

        let httpResponse = try #require(urlResponse as? HTTPURLResponse)
        #expect(httpResponse.statusCode == statusCode.rawValue)
    }


    @Test
    mutating func fixedResponseGeneratorWithErrorResultReturnsError() async throws {
        let error = randomError()
        let delay = Duration.milliseconds(randomInt(in: 10 ... 100))

        let generator = SimulatedURLRequestLoader.FixedResponseGenerator(
            result: .failure(error),
            delay: delay
        )

        let requestComponents = try #require(
            SimulatedURLRequestLoader.RequestComponents(urlRequest: randomURLRequest())
        )

        let result = await generator.response(for: requestComponents)

        let (responseResult, responseDelay) = try #require(result)
        #expect(responseDelay == delay)

        #expect(throws: error) {
            _ = try responseResult.get()
        }
    }


    @Test
    mutating func respondWithErrorCreatesResponder() throws {
        let loader = SimulatedURLRequestLoader()
        let error = randomError()
        let delay = Duration.milliseconds(randomInt(in: 10 ... 100))
        let maxResponses = randomInt(in: 2 ... 5)
        let requestConditions = Array(count: randomInt(in: 2 ... 4)) { MockRequestCondition() }

        let responder = loader.respond(
            with: error,
            delay: delay,
            maxResponses: maxResponses,
            when: requestConditions
        )

        #expect(loader.responders == [responder])
        #expect(responder.maxResponses == maxResponses)
        #expect(responder.requestConditions as? [MockRequestCondition] == requestConditions)

        let generator = try #require(responder.responseGenerator as? SimulatedURLRequestLoader.FixedResponseGenerator)
        #expect(generator.delay == delay)

        #expect(throws: error) {
            try generator.result.get()
        }
    }


    @Test
    mutating func respondWithDataBodyCreatesResponder() throws {
        let loader = SimulatedURLRequestLoader()
        let statusCode = randomHTTPStatusCode()
        let headerItems = Set(count: randomInt(in: 2 ... 4)) { randomHTTPHeaderItem() }
        let body = randomData()
        let delay = Duration.milliseconds(randomInt(in: 10 ... 100))
        let maxResponses = randomInt(in: 2 ... 5)
        let requestConditions = Array(count: randomInt(in: 2 ... 4)) { MockRequestCondition() }

        let responder = loader.respond(
            with: statusCode,
            headerItems: headerItems,
            body: body,
            delay: delay,
            maxResponses: maxResponses,
            when: requestConditions
        )

        #expect(loader.responders == [responder])
        #expect(responder.maxResponses == maxResponses)
        #expect(responder.requestConditions as? [MockRequestCondition] == requestConditions)

        let generator = try #require(responder.responseGenerator as? SimulatedURLRequestLoader.FixedResponseGenerator)
        #expect(generator.delay == delay)

        #expect(throws: Never.self) {
            let template = try generator.result.get()
            #expect(template.statusCode == statusCode)
            #expect(template.headerItems == headerItems)
            #expect(template.body == body)
        }
    }


    @Test
    mutating func respondWithStringBodyCreatesResponder() throws {
        let loader = SimulatedURLRequestLoader()
        let statusCode = randomHTTPStatusCode()
        let headerItems = Set(count: randomInt(in: 2 ... 4)) { randomHTTPHeaderItem() }
        let bodyString = randomAlphanumericString()
        let encoding = randomElement(in: [String.Encoding.utf8, .utf16, .ascii, .isoLatin1])!
        let delay = Duration.milliseconds(randomInt(in: 10 ... 100))
        let maxResponses = randomInt(in: 2 ... 5)
        let requestConditions = Array(count: randomInt(in: 2 ... 4)) { MockRequestCondition() }

        let responder = loader.respond(
            with: statusCode,
            headerItems: headerItems,
            body: bodyString,
            encoding: encoding,
            delay: delay,
            maxResponses: maxResponses,
            when: requestConditions
        )

        #expect(loader.responders == [responder])
        #expect(responder.maxResponses == maxResponses)
        #expect(responder.requestConditions as? [MockRequestCondition] == requestConditions)

        let generator = try #require(responder.responseGenerator as? SimulatedURLRequestLoader.FixedResponseGenerator)
        #expect(generator.delay == delay)

        #expect(throws: Never.self) {
            let template = try generator.result.get()
            #expect(template.statusCode == statusCode)
            #expect(template.headerItems == headerItems)
            #expect(template.body == bodyString.data(using: encoding))
        }
    }


    @Test
    mutating func respondWithEncodableBodyCreatesResponder() throws {
        struct TestEncodable: Codable, Equatable {
            let name: String
            let value: Int
        }

        let loader = SimulatedURLRequestLoader()
        let statusCode = randomHTTPStatusCode()
        let headerItems = Set(count: randomInt(in: 2 ... 4)) { randomHTTPHeaderItem() }
        let body = TestEncodable(name: randomAlphanumericString(), value: randomInt(in: 1 ... 100))
        let encoder = PropertyListEncoder()
        let delay = Duration.milliseconds(randomInt(in: 10 ... 100))
        let maxResponses = randomInt(in: 2 ... 5)
        let requestConditions = Array(count: randomInt(in: 2 ... 4)) { MockRequestCondition() }

        let responder = loader.respond(
            with: statusCode,
            headerItems: headerItems,
            body: body,
            encoder: encoder,
            delay: delay,
            maxResponses: maxResponses,
            when: requestConditions
        )

        let expectedBody = try encoder.encode(body)

        #expect(loader.responders == [responder])
        #expect(responder.maxResponses == maxResponses)
        #expect(responder.requestConditions as? [MockRequestCondition] == requestConditions)

        let generator = try #require(responder.responseGenerator as? SimulatedURLRequestLoader.FixedResponseGenerator)
        #expect(generator.delay == delay)

        #expect(throws: Never.self) {
            let template = try generator.result.get()
            #expect(template.statusCode == statusCode)
            #expect(template.headerItems == headerItems)
            #expect(template.body == expectedBody)
        }
    }
}
