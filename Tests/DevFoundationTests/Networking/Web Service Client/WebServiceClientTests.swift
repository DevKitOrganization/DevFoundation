//
//  WebServiceClientTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/19/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct WebServiceClientTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func testWebServiceClientInit() {
        let httpClient = HTTPClient<String>(urlRequestLoader: MockURLRequestLoader())
        let baseURLConfiguration = MockBaseURLConfiguration()

        let client = WebServiceClient(
            httpClient: httpClient,
            baseURLConfiguration: baseURLConfiguration
        )

        #expect(client.httpClient === httpClient)
        #expect(client.baseURLConfiguration === baseURLConfiguration)
    }


    @Test(arguments: [false, true])
    mutating func loadThrowsWhenURLRequestCreationThrows(usesLoadUsingSyntax: Bool) async {
        let baseURLConfiguration = MockBaseURLConfiguration()
        let baseURL = randomURL(includeFragment: false, includeQueryItems: false)
        baseURLConfiguration.urlStub = Stub(defaultReturnValue: baseURL)

        let expectedError = randomError()
        let request = MockWebServiceRequest(
            httpMethod: randomHTTPMethod(),
            headerItems: [],
            context: randomAlphanumericString(),
            baseURL: randomInt(in: .min ... .max),
            pathComponents: [],
            fragment: nil,
            queryItems: [],
            httpBodyResult: .failure(expectedError)
        )

        let httpClient = HTTPClient<String>(urlRequestLoader: MockURLRequestLoader())
        let client = WebServiceClient(
            httpClient: httpClient,
            baseURLConfiguration: baseURLConfiguration
        )

        do {
            _ = try await usesLoadUsingSyntax ? request.load(using: client) : client.load(request)
            Issue.record("does not throw error")
        } catch let error as InvalidWebServiceRequestError {
            #expect(!error.debugDescription.isEmpty)
            #expect(error.underlyingError as? MockError == expectedError)
        } catch {
            Issue.record("throws unexpected error: \(error)")
        }
    }


    @Test(arguments: [false, true])
    mutating func loadThrowsWhenHTTPClientThrows(usesLoadUsingSyntax: Bool) async throws {
        let baseURLConfiguration = MockBaseURLConfiguration()
        let baseURL = randomURL(includeFragment: false, includeQueryItems: false)
        baseURLConfiguration.urlStub = Stub(defaultReturnValue: baseURL)

        let request = MockWebServiceRequest(
            httpMethod: randomHTTPMethod(),
            headerItems: [],
            context: randomAlphanumericString(),
            baseURL: randomInt(in: .min ... .max),
            pathComponents: [],
            fragment: nil,
            queryItems: [],
            httpBodyResult: .success(randomHTTPBody())
        )

        let expectedError = randomError()
        let urlRequestLoader = MockURLRequestLoader()
        urlRequestLoader.dataStub = ThrowingStub(defaultError: expectedError)

        let httpClient = HTTPClient<String>(urlRequestLoader: urlRequestLoader)
        let client = WebServiceClient(
            httpClient: httpClient,
            baseURLConfiguration: baseURLConfiguration
        )

        await #expect(throws: expectedError) {
            try await usesLoadUsingSyntax ? request.load(using: client) : client.load(request)
        }

        let expectedURLRequest = try request.urlRequest(with: baseURLConfiguration)
        #expect(urlRequestLoader.dataStub.callArguments == [expectedURLRequest])
    }


    @Test(arguments: [false, true])
    mutating func loadThrowsWhenMapResponseThrows(usesLoadUsingSyntax: Bool) async throws {
        let baseURLConfiguration = MockBaseURLConfiguration()
        let baseURL = randomURL(includeFragment: false, includeQueryItems: false)
        baseURLConfiguration.urlStub = Stub(defaultReturnValue: baseURL)

        let request = MockWebServiceRequest(
            httpMethod: randomHTTPMethod(),
            headerItems: [],
            context: randomAlphanumericString(),
            baseURL: randomInt(in: .min ... .max),
            pathComponents: [],
            fragment: nil,
            queryItems: [],
            httpBodyResult: .success(randomHTTPBody())
        )
        let expectedError = randomError()
        request.mapResponseStub = ThrowingStub(defaultError: expectedError)

        let response = randomHTTPResponse()
        let urlRequestLoader = MockURLRequestLoader()
        urlRequestLoader.dataStub = ThrowingStub(defaultReturnValue: (response.body, response.httpURLResponse))

        let httpClient = HTTPClient<String>(urlRequestLoader: urlRequestLoader)
        let client = WebServiceClient(
            httpClient: httpClient,
            baseURLConfiguration: baseURLConfiguration
        )

        await #expect(throws: expectedError) {
            try await usesLoadUsingSyntax ? request.load(using: client) : client.load(request)
        }

        let expectedURLRequest = try request.urlRequest(with: baseURLConfiguration)
        #expect(urlRequestLoader.dataStub.callArguments == [expectedURLRequest])
        #expect(request.mapResponseStub.callArguments == [response])
    }


    @Test(arguments: [false, true])
    mutating func loadReturnsSuccessfulMappedResponse(usesLoadUsingSyntax: Bool) async throws {
        let baseURLConfiguration = MockBaseURLConfiguration()
        let baseURL = randomURL(includeFragment: false, includeQueryItems: false)
        baseURLConfiguration.urlStub = Stub(defaultReturnValue: baseURL)

        let request = MockWebServiceRequest(
            httpMethod: randomHTTPMethod(),
            headerItems: Array(count: randomInt(in: 0 ... 5)) { randomHTTPHeaderItem() },
            context: randomAlphanumericString(),
            baseURL: randomInt(in: .min ... .max),
            pathComponents: Array(count: randomInt(in: 1 ... 5)) { randomURLPathComponent() },
            fragment: randomOptional(randomAlphanumericString()),
            queryItems: Array(count: randomInt(in: 1 ... 5)) { randomURLQueryItem() },
            httpBodyResult: .success(randomHTTPBody())
        )
        let expectedMappedResponse = randomBasicLatinString()
        request.mapResponseStub = ThrowingStub(defaultReturnValue: expectedMappedResponse)

        let httpResponse = randomHTTPResponse()
        let urlRequestLoader = MockURLRequestLoader()
        urlRequestLoader.dataStub = ThrowingStub(
            defaultReturnValue: (httpResponse.body, httpResponse.httpURLResponse))

        let httpClient = HTTPClient<String>(urlRequestLoader: urlRequestLoader)
        let client = WebServiceClient(
            httpClient: httpClient,
            baseURLConfiguration: baseURLConfiguration
        )

        let response = try await usesLoadUsingSyntax ? request.load(using: client) : client.load(request)
        #expect(response == expectedMappedResponse)

        let expectedURLRequest = try request.urlRequest(with: baseURLConfiguration)
        #expect(urlRequestLoader.dataStub.callArguments == [expectedURLRequest])
        #expect(request.mapResponseStub.callArguments == [httpResponse])
    }
}
