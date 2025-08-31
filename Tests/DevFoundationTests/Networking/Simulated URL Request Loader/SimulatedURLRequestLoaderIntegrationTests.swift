//
//  SimulatedURLRequestLoaderIntegrationTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/31/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct SimulatedURLRequestLoaderIntegrationTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func webServiceClientWithSimulatedURLRequestLoaderLoadsJSONRequest() async throws {
        let requestBody = TestRequestBody(
            name: randomAlphanumericString(),
            age: randomInt(in: 1 ... 100)
        )

        let expectedResponse = TestResponseBody(
            id: randomInt(in: 0 ... .max),
            message: randomAlphanumericString(),
            active: randomBool()
        )

        let loader = SimulatedURLRequestLoader()
        loader.respond(
            with: .ok,
            body: expectedResponse,
            when: [
                .httpMethodEquals(.post),
                .pathMatches(#/.*/api/test/#, percentEncoded: false),
            ]
        )

        let client = WebServiceClient(
            httpClient: HTTPClient<Void>(urlRequestLoader: loader),
            baseURLConfiguration: SingleBaseURLConfiguration(baseURL: randomURL())
        )


        let request = TestWebServiceRequest(jsonBody: requestBody)
        #expect(try await client.load(request) == expectedResponse)
    }


    @Test
    mutating func webServiceClientWithSimulatedURLRequestLoaderThrowsError() async throws {
        let requestBody = TestRequestBody(
            name: randomAlphanumericString(),
            age: randomInt(in: 1 ... 100)
        )

        let error = randomError()

        let loader = SimulatedURLRequestLoader()
        loader.respond(
            with: error,
            when: [
                .httpMethodEquals(.post),
                .pathMatches(#/.*/api/test/#, percentEncoded: false),
            ]
        )

        let client = WebServiceClient(
            httpClient: HTTPClient<Void>(urlRequestLoader: loader),
            baseURLConfiguration: SingleBaseURLConfiguration(baseURL: randomURL())
        )

        let request = TestWebServiceRequest(jsonBody: requestBody)
        await #expect(throws: error) {
            try await client.load(request)
        }
    }


    @Test
    mutating func webServiceClientWithSimulatedURLRequestLoaderThrowsUnfulfillableError() async throws {
        let requestBody = TestRequestBody(
            name: randomAlphanumericString(),
            age: randomInt(in: 1 ... 100)
        )

        let error = randomError()

        let loader = SimulatedURLRequestLoader()
        loader.respond(
            with: error,
            when: [.httpMethodEquals(.get)]
        )

        let client = WebServiceClient(
            httpClient: HTTPClient<Void>(urlRequestLoader: loader),
            baseURLConfiguration: SingleBaseURLConfiguration(baseURL: randomURL())
        )

        let request = TestWebServiceRequest(jsonBody: requestBody)
        await #expect(throws: SimulatedURLRequestLoader.UnfulfillableRequestError.self) {
            try await client.load(request)
        }
    }
}


// MARK: - Test Types

private struct TestRequestBody: Codable, Hashable {
    let name: String
    let age: Int
}


private struct TestResponseBody: Codable, Hashable {
    let id: Int
    let message: String
    let active: Bool
}


private struct TestWebServiceRequest: JSONBodyWebServiceRequest {
    typealias Context = Void
    typealias BaseURLConfiguration = SingleBaseURLConfiguration

    let jsonBody: TestRequestBody


    var httpMethod: HTTPMethod {
        return .post
    }


    var pathComponents: [URLPathComponent] {
        return ["api", "test"]
    }


    func mapResponse(_ response: HTTPResponse<Data>) throws -> TestResponseBody {
        return try response.decode(TestResponseBody.self, decoder: JSONDecoder()).body
    }
}
