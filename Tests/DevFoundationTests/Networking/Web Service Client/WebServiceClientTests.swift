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
    mutating func initSetsProperties() {
        let urlRequestLoader = MockURLRequestLoader()
        let authenticator = MockHTTPRequestAuthenticator()
        let requestInterceptors = Array(count: random(Int.self, in: 3 ... 5)) {
            MockHTTPClientRequestInterceptor()
        }
        let responseInterceptors = Array(count: random(Int.self, in: 3 ... 5)) {
            MockHTTPClientResponseInterceptor()
        }
        let baseURLConfiguration = MockBaseURLConfiguration()

        let client = WebServiceClient(
            urlRequestLoader: urlRequestLoader,
            authenticator: authenticator,
            baseURLConfiguration: baseURLConfiguration,
            requestInterceptors: requestInterceptors,
            responseInterceptors: responseInterceptors
        )

        #expect(client.urlRequestLoader as? MockURLRequestLoader === urlRequestLoader)
        #expect(client.authenticator === authenticator)
        #expect(client.baseURLConfiguration === baseURLConfiguration)
        #expect(client.requestInterceptors as? [MockHTTPClientRequestInterceptor] == requestInterceptors)
        #expect(client.responseInterceptors as? [MockHTTPClientResponseInterceptor] == responseInterceptors)

        let httpClient = client.authenticatingHTTPClient
        #expect(httpClient.urlRequestLoader as? MockURLRequestLoader === urlRequestLoader)
        #expect(httpClient.authenticator === authenticator)
        #expect(httpClient.requestInterceptors as? [MockHTTPClientRequestInterceptor] == requestInterceptors)
        #expect(httpClient.responseInterceptors as? [MockHTTPClientResponseInterceptor] == responseInterceptors)
    }


    @Test(arguments: [false, true])
    mutating func loadThrowsWhenURLRequestCreationThrows(usesLoadUsingSyntax: Bool) async {
        // Set up the base URL configuration return a URL
        let baseURLConfiguration = MockBaseURLConfiguration()
        let baseURL = randomURL(includeFragment: false, includeQueryItems: false)
        baseURLConfiguration.urlStub = Stub(defaultReturnValue: baseURL)

        // Set up a request to throw an error when constructing the HTTP body
        let expectedError = randomError()
        let request = MockWebServiceRequest(
            httpMethod: randomHTTPMethod(),
            headerItems: [],
            authenticatorContext: randomAuthenticatorContext(),
            baseURL: random(Int.self, in: .min ... .max),
            pathComponents: [],
            fragment: nil,
            queryItems: [],
            httpBodyResult: .failure(expectedError)
        )

        // Set up our web service client to use our mocks
        let client = WebServiceClient(
            urlRequestLoader: MockURLRequestLoader(),
            authenticator: MockHTTPRequestAuthenticator(),
            baseURLConfiguration: baseURLConfiguration
        )

        // Perform a load using the appropriate syntax and expect an InvalidWebServiceRequestError to be thrown
        // during URL request creation
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
    mutating func loadThrowsWhenURLRequestLoadThrows(usesLoadUsingSyntax: Bool) async throws {
        // Set up the base URL configuration to return a URL
        let baseURLConfiguration = MockBaseURLConfiguration()
        let baseURL = randomURL(includeFragment: false, includeQueryItems: false)
        baseURLConfiguration.urlStub = Stub(defaultReturnValue: baseURL)

        // Set up a request that can be used to construct a URL request
        let request = MockWebServiceRequest(
            httpMethod: randomHTTPMethod(),
            headerItems: [],
            authenticatorContext: randomAuthenticatorContext(),
            baseURL: random(Int.self, in: .min ... .max),
            pathComponents: [],
            fragment: nil,
            queryItems: [],
            httpBodyResult: .success(randomHTTPBody())
        )

        // Set up the authenticator to successfully prepare a request
        let preparedRequest = randomURLRequest()
        let authenticator = MockHTTPRequestAuthenticator()
        authenticator.prepareStub = .init(defaultResult: .success(preparedRequest))

        // Set up the URL request loader to fail
        let expectedError = randomError()
        let urlRequestLoader = MockURLRequestLoader()
        urlRequestLoader.dataStub = .init(defaultResult: .failure(expectedError))

        // Set up our web service client to use our mocks
        let client = WebServiceClient(
            urlRequestLoader: urlRequestLoader,
            authenticator: authenticator,
            baseURLConfiguration: baseURLConfiguration
        )

        // Expect the URL request loader error to propagate
        await #expect(throws: expectedError) {
            try await usesLoadUsingSyntax ? request.load(using: client) : client.load(request)
        }

        // Verify that authenticator.prepare(_:context:previousFailures:) was called with the correct arguments
        #expect(authenticator.prepareStub.calls.count == 1)
        let prepareArguments = try #require(authenticator.prepareStub.callArguments.first)
        let expectedURLRequest = try #require(try request.urlRequest(with: baseURLConfiguration))
        #expect(prepareArguments.request == expectedURLRequest)
        #expect(prepareArguments.context == request.authenticatorContext)
        #expect(prepareArguments.previousFailures.isEmpty)

        // Verify that urlRequestLoader.data(for:) was called with the correct arguments
        #expect(urlRequestLoader.dataStub.callArguments == [preparedRequest])
    }


    @Test(arguments: [false, true])
    mutating func loadThrowsWhenMapResponseThrows(usesLoadUsingSyntax: Bool) async throws {
        // Set up the base URL configuration to return a URL
        let baseURLConfiguration = MockBaseURLConfiguration()
        let baseURL = randomURL(includeFragment: false, includeQueryItems: false)
        baseURLConfiguration.urlStub = Stub(defaultReturnValue: baseURL)

        // Set up a request that can be used to construct a URL request, but throws during mapResponse
        let request = MockWebServiceRequest(
            httpMethod: randomHTTPMethod(),
            headerItems: [],
            authenticatorContext: randomAuthenticatorContext(),
            baseURL: random(Int.self, in: .min ... .max),
            pathComponents: [],
            fragment: nil,
            queryItems: [],
            httpBodyResult: .success(randomHTTPBody())
        )
        let expectedError = randomError()
        request.mapResponseStub = .init(defaultResult: .failure(expectedError))

        // Set up the authenticator to successfully prepare a request and not find any authentication failures
        let preparedRequest = randomURLRequest()
        let authenticator = MockHTTPRequestAuthenticator()
        authenticator.prepareStub = .init(defaultResult: .success(preparedRequest))
        authenticator.throwStub = .init(defaultError: nil)

        // Set up the URL request loader to succeed
        let response = randomHTTPResponse()
        let urlRequestLoader = MockURLRequestLoader()
        urlRequestLoader.dataStub = .init(defaultResult: .success((response.body, response.httpURLResponse)))

        // Set up our web service client to use our mocks
        let client = WebServiceClient(
            urlRequestLoader: urlRequestLoader,
            authenticator: authenticator,
            baseURLConfiguration: baseURLConfiguration
        )

        // Expect the map response error to propagate
        await #expect(throws: expectedError) {
            try await usesLoadUsingSyntax ? request.load(using: client) : client.load(request)
        }

        // Verify that authenticator.prepare(_:context:previousFailures:) was called with the correct arguments
        #expect(authenticator.prepareStub.calls.count == 1)
        let prepareArguments = try #require(authenticator.prepareStub.callArguments.first)
        let expectedURLRequest = try #require(try request.urlRequest(with: baseURLConfiguration))
        #expect(prepareArguments.request == expectedURLRequest)
        #expect(prepareArguments.context == request.authenticatorContext)
        #expect(prepareArguments.previousFailures.isEmpty)

        // Verify that urlRequestLoader.data(for:) was called with the correct arguments
        #expect(urlRequestLoader.dataStub.callArguments == [preparedRequest])

        // Verify that mapResponse(_:) was called with the correct argument
        #expect(request.mapResponseStub.callArguments == [response])
    }


    @Test(arguments: [false, true])
    mutating func loadReturnsWhenMappedResponse(usesLoadUsingSyntax: Bool) async throws {
        // This test will mock all the moving parts including request interceptors and response interceptors

        // Set up the base URL configuration to return a URL
        let baseURLConfiguration = MockBaseURLConfiguration()
        let baseURL = randomURL(includeFragment: false, includeQueryItems: false)
        baseURLConfiguration.urlStub = Stub(defaultReturnValue: baseURL)

        // Set up a request that can be used to construct a URL request and succeeds at mapping a response
        let request = MockWebServiceRequest(
            httpMethod: randomHTTPMethod(),
            headerItems: Array(count: random(Int.self, in: 0 ... 5)) { randomHTTPHeaderItem() },
            authenticatorContext: randomAuthenticatorContext(),
            baseURL: random(Int.self, in: .min ... .max),
            pathComponents: Array(count: random(Int.self, in: 1 ... 5)) { randomURLPathComponent() },
            fragment: randomOptional(randomAlphanumericString()),
            queryItems: Array(count: random(Int.self, in: 1 ... 5)) { randomURLQueryItem() },
            httpBodyResult: .success(randomHTTPBody())
        )
        let expectedMappedResponse = randomBasicLatinString()
        request.mapResponseStub = .init(defaultResult: .success(expectedMappedResponse))

        // Set up the authenticator to successfully prepare a request and not find any authentication failures
        let preparedRequest = randomURLRequest()
        let authenticator = MockHTTPRequestAuthenticator()
        authenticator.prepareStub = .init(defaultResult: .success(preparedRequest))
        authenticator.throwStub = .init(defaultError: nil)

        // Set up request interceptors
        let interceptedRequests = Array(count: random(Int.self, in: 4 ... 6)) {
            randomURLRequest()
        }
        let requestInterceptors = interceptedRequests.map { (request) in
            let interceptor = MockHTTPClientRequestInterceptor()
            interceptor.interceptStub = .init(defaultResult: .success(request))
            return interceptor
        }

        // Set up response interceptors
        let interceptedResponses = Array(count: random(Int.self, in: 4 ... 6)) {
            randomHTTPResponse()
        }
        let responseInterceptors = interceptedResponses.map { (response) in
            let interceptor = MockHTTPClientResponseInterceptor()
            interceptor.interceptStub = .init(defaultResult: .success(response))
            return interceptor
        }

        // Set up the URL request loader to succeed
        let loadResponse = randomHTTPResponse()
        let urlRequestLoader = MockURLRequestLoader()
        urlRequestLoader.dataStub = .init(defaultResult: .success((loadResponse.body, loadResponse.httpURLResponse)))

        // Set up our web service client to use our mocks
        let client = WebServiceClient(
            urlRequestLoader: urlRequestLoader,
            authenticator: authenticator,
            baseURLConfiguration: baseURLConfiguration,
            requestInterceptors: requestInterceptors,
            responseInterceptors: responseInterceptors
        )

        // Expect the map response error to propagate
        let response = try await usesLoadUsingSyntax ? request.load(using: client) : client.load(request)
        #expect(response == expectedMappedResponse)

        // Verify that authenticator.prepare(_:context:previousFailures:) was called with the correct arguments
        #expect(authenticator.prepareStub.calls.count == 1)
        let prepareArguments = try #require(authenticator.prepareStub.callArguments.first)
        let expectedURLRequest = try #require(try request.urlRequest(with: baseURLConfiguration))
        #expect(prepareArguments.request == expectedURLRequest)
        #expect(prepareArguments.context == request.authenticatorContext)
        #expect(prepareArguments.previousFailures.isEmpty)

        // Verify that the request interceptors were called with the correct arguments
        for (i, interceptor) in requestInterceptors.enumerated() {
            #expect(interceptor.interceptStub.calls.count == 1)
            let arguments = try #require(interceptor.interceptStub.callArguments.first)
            let expectedRequest = i == 0 ? preparedRequest : interceptedRequests[i - 1]
            #expect(arguments.request == expectedRequest)
        }

        // Verify that urlRequestLoader.data(for:) was called with the correct arguments
        let finalRequest = try #require(interceptedRequests.last)
        #expect(urlRequestLoader.dataStub.callArguments == [finalRequest])

        // Verify that the response interceptors were called with the correct arguments
        for (i, interceptor) in responseInterceptors.enumerated() {
            let arguments = try #require(interceptor.interceptStub.callArguments.first)
            let expectedResponse = i == 0 ? loadResponse : interceptedResponses[i - 1]
            #expect(arguments.response == expectedResponse)
            #expect(arguments.request == finalRequest)
        }

        // Verify that mapResponse(_:) was called with the correct argument
        let finalResponse = try #require(interceptedResponses.last)
        #expect(request.mapResponseStub.callArguments == [finalResponse])
    }
}
