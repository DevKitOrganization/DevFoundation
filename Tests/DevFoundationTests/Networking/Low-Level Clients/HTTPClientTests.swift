//
//  HTTPClientTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/16/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing


struct HTTPClientTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initSetsProperties() {
        let urlRequestLoader = MockURLRequestLoader()
        let requestInterceptors = Array(count: random(Int.self, in: 3 ... 5)) {
            MockHTTPClientRequestInterceptor()
        }
        let responseInterceptors = Array(count: random(Int.self, in: 3 ... 5)) {
            MockHTTPClientResponseInterceptor()
        }

        let client = HTTPClient(
            urlRequestLoader: urlRequestLoader,
            requestInterceptors: requestInterceptors,
            responseInterceptors: responseInterceptors
        )

        #expect(client.urlRequestLoader as? MockURLRequestLoader === urlRequestLoader)
        #expect(client.requestInterceptors as? [MockHTTPClientRequestInterceptor] == requestInterceptors)
        #expect(client.responseInterceptors as? [MockHTTPClientResponseInterceptor] == responseInterceptors)
    }


    @Test
    mutating func loadThrowsWhenRequestInterceptorThrows() async throws {
        // Set up the original request as well as some for the interceptors to return
        let originalRequest = randomURLRequest()
        let interceptedRequests = Array(count: random(Int.self, in: 4 ... 6)) {
            randomURLRequest()
        }

        // Create interceptors that return the specified requests
        let requestInterceptors = interceptedRequests.map { (request) in
            let interceptor = MockHTTPClientRequestInterceptor()
            interceptor.interceptStub = .init(defaultResult: .success(request))
            return interceptor
        }

        // Pick an interceptor at random that will throw an error
        let expectedError = randomError()
        let throwingInterceptorIndex = random(Int.self, in: 1 ..< interceptedRequests.count - 1)
        requestInterceptors[throwingInterceptorIndex].interceptStub.defaultResult = .failure(expectedError)

        // Set up the client
        let client = HTTPClient(urlRequestLoader: MockURLRequestLoader(), requestInterceptors: requestInterceptors)

        // Expect the request interceptor’s error to be propagated
        await #expect(throws: expectedError) {
            try await client.load(originalRequest)
        }

        // Verify that each interceptor up to the one that threw was called with the right parameters. Interceptors
        // after the one that threw should not have been called
        for (i, interceptor) in requestInterceptors.enumerated() {
            let expectedCalls = i <= throwingInterceptorIndex ? 1 : 0
            #expect(interceptor.interceptStub.calls.count == expectedCalls)

            if expectedCalls > 0 {
                let arguments = try #require(interceptor.interceptStub.callArguments.first)

                let expectedRequest = i == 0 ? originalRequest : interceptedRequests[i - 1]
                #expect(arguments.request == expectedRequest)
                #expect(arguments.client === client)
            }
        }
    }


    @Test
    mutating func loadCancelsWhenCanceledDuringRequestInterception() async {
        // Set up the original request as well as some for the interceptors to return
        let requestInterceptors = Array(count: random(Int.self, in: 3 ... 5)) {
            let interceptor = MockHTTPClientRequestInterceptor()
            interceptor.interceptStub = .init(defaultResult: .success(randomURLRequest()))
            return interceptor
        }

        // Pick a random interceptor that will cancel the task
        randomElement(in: requestInterceptors)!.interceptPrologue = { withUnsafeCurrentTask { $0?.cancel() } }

        // Set up the client
        let client = HTTPClient(urlRequestLoader: MockURLRequestLoader(), requestInterceptors: requestInterceptors)

        // Load the request and expect a cancellation error
        await #expect(throws: CancellationError.self) {
            try await client.load(randomURLRequest())
        }
    }


    @Test
    mutating func loadThrowsWhenURLRequestLoaderThrows() async throws {
        // Set up the original request as well as some for the interceptors to return
        let originalRequest = randomURLRequest()
        let interceptedRequests = Array(count: random(Int.self, in: 4 ... 6)) {
            randomURLRequest()
        }

        // Create interceptors that return the specified requests
        let requestInterceptors = interceptedRequests.map { (request) in
            let interceptor = MockHTTPClientRequestInterceptor()
            interceptor.interceptStub = .init(defaultResult: .success(request))
            return interceptor
        }

        // Set up a URL request loader that throws
        let urlRequestLoader = MockURLRequestLoader()
        let expectedError = randomError()
        urlRequestLoader.dataStub = .init(defaultResult: .failure(expectedError))

        // Set up the client
        let client = HTTPClient(urlRequestLoader: urlRequestLoader, requestInterceptors: requestInterceptors)

        // Load the request and expect the URL request loader’s error to be propagated
        await #expect(throws: expectedError) {
            try await client.load(originalRequest)
        }

        // Verify that URL request loader was asked to load the last iterceptor’s return value
        #expect(urlRequestLoader.dataStub.calls.count == 1)
        let actualRequest = try #require(urlRequestLoader.dataStub.callArguments.first)
        #expect(actualRequest == interceptedRequests.last)
    }


    @Test
    mutating func loadThrowsWhenURLRequestLoaderReturnsNonHTTPURLResponse() async {
        // Set up a URL request loader that returns a non-HTTPURLResponse
        let urlRequestLoader = MockURLRequestLoader()
        let expectedResponse = URLResponse(
            url: randomURL(),
            mimeType: nil,
            expectedContentLength: random(Int.self, in: 256 ... 1024),
            textEncodingName: nil
        )
        urlRequestLoader.dataStub = .init(defaultResult: .success((randomData(), expectedResponse)))

        // Set up the client
        let client = HTTPClient(urlRequestLoader: urlRequestLoader)

        // Load the request and expect a NonHTTPURLResponse error
        await #expect(throws: NonHTTPURLResponseError(urlResponse: expectedResponse)) {
            try await client.load(randomURLRequest())
        }
    }


    @Test
    mutating func loadCancelsWhenCanceledDuringURLRequestLoading() async {
        // Set up a URL request loader that returns an HTTPURLResponse
        let urlRequestLoader = MockURLRequestLoader()
        let expectedResponse = randomHTTPURLResponse()

        urlRequestLoader.dataPrologue = { withUnsafeCurrentTask { $0?.cancel() } }
        urlRequestLoader.dataStub = .init(defaultResult: .success((randomData(), expectedResponse)))

        // Set up the client
        let client = HTTPClient(urlRequestLoader: urlRequestLoader)

        // Load the request and expect a cancellation error
        await #expect(throws: CancellationError.self) {
            try await client.load(randomURLRequest())
        }
    }


    @Test
    mutating func loadThrowsWhenResponseInterceptorThrows() async throws {
        let interceptedResponses = Array(count: random(Int.self, in: 4 ... 6)) {
            randomHTTPResponse()
        }

        // Create interceptors that return the specified requests
        let responseInterceptors = interceptedResponses.map { (response) in
            let interceptor = MockHTTPClientResponseInterceptor()
            interceptor.interceptStub = .init(defaultResult: .success(response))
            return interceptor
        }

        // Pick a random interceptor that will throw an error
        let expectedError = randomError()
        let throwingInterceptorIndex = random(Int.self, in: 1 ..< interceptedResponses.count - 1)
        responseInterceptors[throwingInterceptorIndex].interceptStub.defaultResult = .failure(expectedError)

        // Set up a URL request loader that succeeds
        let urlRequestLoader = MockURLRequestLoader()
        let originalResponse = randomHTTPResponse()
        urlRequestLoader.dataStub = .init(
            defaultResult: .success((originalResponse.body, originalResponse.httpURLResponse))
        )

        // Set up the client
        let client = HTTPClient(urlRequestLoader: urlRequestLoader, responseInterceptors: responseInterceptors)

        // Expect the response interceptor’s error to be propagated
        let request = randomURLRequest()
        await #expect(throws: expectedError) {
            try await client.load(request)
        }

        // Verify that each interceptor up to the one that threw was called with the right parameters. Interceptors
        // after the one that threw should not have been called
        for (i, interceptor) in responseInterceptors.enumerated() {
            let expectedCalls = i <= throwingInterceptorIndex ? 1 : 0
            #expect(interceptor.interceptStub.calls.count == expectedCalls)

            if expectedCalls > 0 {
                let arguments = try #require(interceptor.interceptStub.callArguments.first)

                let expectedResponse = i == 0 ? originalResponse : interceptedResponses[i - 1]
                #expect(arguments.response == expectedResponse)
                #expect(arguments.client === client)
                #expect(arguments.request == request)
            }
        }
    }


    @Test
    mutating func loadCancelsWhenCanceledDuringResponseInterception() async {
        // Set up some responses that will be returned by our response interceptors
        let interceptedResponses = Array(count: random(Int.self, in: 4 ... 6)) {
            randomHTTPResponse()
        }

        // Create interceptors that return the specified responses
        let responseInterceptors = interceptedResponses.map { (response) in
            let interceptor = MockHTTPClientResponseInterceptor()
            interceptor.interceptStub = .init(defaultResult: .success(response))
            return interceptor
        }

        // Pick a random interceptor that will cancel the task
        randomElement(in: responseInterceptors)!.interceptPrologue = { withUnsafeCurrentTask { $0?.cancel() } }

        // Set up a URL request loader that succeeds
        let urlRequestLoader = MockURLRequestLoader()
        urlRequestLoader.dataStub = .init(defaultResult: .success((randomData(), randomHTTPURLResponse())))

        // Set up the client
        let client = HTTPClient(urlRequestLoader: urlRequestLoader, responseInterceptors: responseInterceptors)

        // Load the request and expect a cancellation error
        let request = randomURLRequest()
        await #expect(throws: CancellationError.self) {
            try await client.load(request)
        }
    }


    @Test
    mutating func loadReturnsWhenAllResponseInterceptorsReturnNonNil() async throws {
        // Set up some responses that will be returned by our response interceptors
        let interceptedResponses = Array(count: random(Int.self, in: 4 ... 6)) {
            randomHTTPResponse()
        }

        // Create interceptors that return the specified responses
        let responseInterceptors = interceptedResponses.map { (response) in
            let interceptor = MockHTTPClientResponseInterceptor()
            interceptor.interceptStub = .init(defaultResult: .success(response))
            return interceptor
        }

        // Set up a URL request loader that succeeds
        let urlRequestLoader = MockURLRequestLoader()
        urlRequestLoader.dataStub = .init(defaultResult: .success((randomData(), randomHTTPURLResponse())))

        // Set up the client
        let client = HTTPClient(urlRequestLoader: urlRequestLoader, responseInterceptors: responseInterceptors)

        // Load the request and expect it to succeed
        let request = randomURLRequest()
        let response = try await client.load(request)
        #expect(response == interceptedResponses.last)
    }


    @Test
    mutating func loadRetriesWhenResponseInterceptorReturnsNil() async {
        // Set up some responses that will be returned by our response interceptors
        let interceptedResponses = Array(count: random(Int.self, in: 4 ... 6)) {
            randomHTTPResponse()
        }

        // Create interceptors that return the specified requests
        let responseInterceptors = interceptedResponses.map { (response) in
            let interceptor = MockHTTPClientResponseInterceptor()
            interceptor.interceptStub = .init(defaultResult: .success(response))
            return interceptor
        }

        // Randomly select a response interceptor that will return nil
        responseInterceptors.randomElement()?.interceptStub.defaultResult = .success(nil)

        // Set up a URL request loader that succeeds on the first call, but fails after that
        let urlRequestLoader = MockURLRequestLoader()
        let expectedError = randomError()
        urlRequestLoader.dataStub = .init(
            defaultResult: .failure(expectedError) ,
            resultQueue: [.success((randomData(), randomHTTPURLResponse()))]
        )

        // Set up the client
        let client = HTTPClient(urlRequestLoader: urlRequestLoader, responseInterceptors: responseInterceptors)

        // Load the request and expect it to fail
        let request = randomURLRequest()
        await #expect(throws: expectedError) {
            try await client.load(request)
        }

        // Verify that the URL request loader was called twice with the original request
        #expect(urlRequestLoader.dataStub.callArguments == [request, request])
    }


    @Test
    mutating func loadCancelsBeforeRetryingWhenCanceledWhileResponseInterceptorReturnsNil() async throws {
        // Set up some responses that will be returned by our response interceptors
        let interceptedResponses = Array(count: random(Int.self, in: 4 ... 6)) {
            randomHTTPResponse()
        }

        // Create interceptors that return the specified requests
        let responseInterceptors = interceptedResponses.map { (response) in
            let interceptor = MockHTTPClientResponseInterceptor()
            interceptor.interceptStub = .init(defaultResult: .success(response))
            return interceptor
        }

        // Randomly select a response interceptor that will return nil
        let retryingInterceptor = responseInterceptors.randomElement()!
        retryingInterceptor.interceptStub.defaultResult = .success(nil)
        retryingInterceptor.interceptPrologue = { withUnsafeCurrentTask { $0?.cancel() } }

        // Set up a URL request loader that succeeds
        let urlRequestLoader = MockURLRequestLoader()
        urlRequestLoader.dataStub = .init(defaultResult: .success((randomData(), randomHTTPURLResponse())))

        // Set up the client
        let client = HTTPClient(urlRequestLoader: urlRequestLoader, responseInterceptors: responseInterceptors)

        // Load the request and expect it to be canceled
        await #expect(throws: CancellationError.self) {
            try await client.load(randomURLRequest())
        }

        // Verify that the URL request loader was called once
        #expect(urlRequestLoader.dataStub.calls.count == 1)
    }
}
