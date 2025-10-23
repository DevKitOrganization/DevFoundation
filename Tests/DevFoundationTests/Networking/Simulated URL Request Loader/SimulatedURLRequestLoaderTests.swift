//
//  SimulatedURLRequestLoaderTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/31/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct SimulatedURLRequestLoaderTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initCreatesEmptyLoader() {
        let loader = SimulatedURLRequestLoader()

        #expect(loader.responders.isEmpty)
        #expect(loader.unfulfilledResponders.isEmpty)
    }


    @Test
    mutating func addResponderAddsResponder() {
        let loader = SimulatedURLRequestLoader()
        let mockResponseGenerator = MockResponseGenerator()
        let responder = SimulatedURLRequestLoader.Responder(
            requestConditions: [.httpMethodEquals(.get)],
            responseGenerator: mockResponseGenerator,
            maxResponses: 1
        )

        loader.add(responder)

        #expect(loader.responders == [responder])
        #expect(loader.unfulfilledResponders == [responder])
    }


    @Test
    mutating func dataForRequestThrowsUnfulfillableRequestErrorWhenNoResponders() async throws {
        let loader = SimulatedURLRequestLoader()
        let urlRequest = randomURLRequest()

        await #expect(throws: SimulatedURLRequestLoader.UnfulfillableRequestError(request: urlRequest)) {
            try await loader.data(for: urlRequest)
        }
    }


    @Test
    mutating func dataForRequestReturnsResponseFromMatchingResponder() async throws {
        let loader = SimulatedURLRequestLoader()
        let expectedData = randomData()
        let expectedStatusCode = randomHTTPStatusCode()
        let urlRequest = randomURLRequest()

        loader.respond(
            with: expectedStatusCode,
            body: expectedData,
            when: []
        )

        let (actualData, response) = try await loader.data(for: urlRequest)

        #expect(actualData == expectedData)
        let httpResponse = try #require(response as? HTTPURLResponse)
        #expect(httpResponse.httpStatusCode == expectedStatusCode)
        #expect(httpResponse.url == urlRequest.url)
    }


    @Test
    mutating func dataForRequestThrowsErrorFromMatchingResponder() async throws {
        let loader = SimulatedURLRequestLoader()
        let expectedError = randomError()
        let urlRequest = randomURLRequest()

        loader.respond(
            with: expectedError,
            when: []
        )

        await #expect(throws: expectedError) {
            try await loader.data(for: urlRequest)
        }
    }


    @Test
    mutating func dataForRequestReturnsSecondResponderWhenFirstDoesNotMatch() async throws {
        let loader = SimulatedURLRequestLoader()
        let data1 = randomData()
        let statusCode1 = randomHTTPStatusCode()
        let data2 = randomData()
        let statusCode2 = randomHTTPStatusCode()

        var urlRequest = randomURLRequest()
        urlRequest.httpMethod = HTTPMethod.get.rawValue

        // First responder only matches POST requests
        loader.respond(
            with: statusCode1,
            body: data1,
            when: [.httpMethodEquals(.post)]
        )

        // Second responder matches GET requests
        loader.respond(
            with: statusCode2,
            body: data2,
            when: [.httpMethodEquals(.get)]
        )

        let (actualData, response) = try await loader.data(for: urlRequest)

        // Should return second responder’s data since first doesn’t match
        #expect(actualData == data2)
        let httpResponse = try #require(response as? HTTPURLResponse)
        #expect(httpResponse.httpStatusCode == statusCode2)
    }


    @Test
    mutating func dataForRequestThrowsUnfulfillableRequestErrorWhenRequestComponentsCannotBeCreated() async throws {
        let loader = SimulatedURLRequestLoader()
        var urlRequest = URLRequest(url: randomURL())
        urlRequest.url = nil

        loader.respond(
            with: .ok,
            body: randomData(),
            when: []
        )

        await #expect(throws: SimulatedURLRequestLoader.UnfulfillableRequestError(request: urlRequest)) {
            try await loader.data(for: urlRequest)
        }
    }
}
