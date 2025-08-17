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
    typealias TestRetryPolicy = MockRetryPolicy<(URLRequest, String), Result<HTTPResponse<Data>, any Error>>

    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func testHTTPClientInit() {
        let urlRequestLoader = MockURLRequestLoader()
        let interceptors = Array(count: randomInt(in: 2 ... 4)) {
            MockHTTPClientInterceptor<String>()
        }
        let retryPolicy = TestRetryPolicy()

        let client = HTTPClient(
            urlRequestLoader: urlRequestLoader,
            interceptors: interceptors,
            retryPolicy: retryPolicy
        )

        #expect(client.urlRequestLoader as? MockURLRequestLoader === urlRequestLoader)
        #expect(client.interceptors as? [MockHTTPClientInterceptor<String>] == interceptors)
        #expect(client.retryPolicy as? TestRetryPolicy == retryPolicy)
    }


    @Test
    func testHTTPClientInitWithDefaults() {
        let urlRequestLoader = MockURLRequestLoader()

        let client = HTTPClient<String>(urlRequestLoader: urlRequestLoader)

        #expect(client.urlRequestLoader as? MockURLRequestLoader === urlRequestLoader)
        #expect(client.interceptors.isEmpty)
        #expect(client.retryPolicy == nil)
    }


    @Test
    mutating func testHTTPClientInterceptorChainExecution() async throws {
        let urlRequestLoader = MockURLRequestLoader()
        let expectedResponse = randomHTTPResponse()
        urlRequestLoader.dataStub = ThrowingStub(
            defaultResult: .success(
                (
                    expectedResponse.body,
                    expectedResponse.httpURLResponse
                )
            )
        )

        let interceptor1 = MockHTTPClientInterceptor<String>()
        let interceptor2 = MockHTTPClientInterceptor<String>()

        let modifiedRequest1 = randomURLRequest()
        let modifiedContext1 = randomAlphanumericString()
        interceptor1.nextArguments = [.init(request: modifiedRequest1, context: modifiedContext1)]
        interceptor1.interceptStub = ThrowingStub(defaultResult: .success(expectedResponse))

        let modifiedRequest2 = randomURLRequest()
        let modifiedContext2 = randomAlphanumericString()
        interceptor2.nextArguments = [.init(request: modifiedRequest2, context: modifiedContext2)]
        interceptor2.interceptStub = ThrowingStub(defaultResult: .success(expectedResponse))

        let client = HTTPClient(urlRequestLoader: urlRequestLoader, interceptors: [interceptor1, interceptor2])

        let originalRequest = randomURLRequest()
        let originalContext = randomAlphanumericString()
        let response = try await client.load(originalRequest, context: originalContext)

        #expect(response == expectedResponse)
        #expect(interceptor1.interceptStub.calls.count == 1)
        #expect(interceptor2.interceptStub.calls.count == 1)

        let args1 = try #require(interceptor1.interceptStub.callArguments.first)
        #expect(args1.request == originalRequest)
        #expect(args1.context == originalContext)

        let args2 = try #require(interceptor2.interceptStub.callArguments.first)
        #expect(args2.request == modifiedRequest1)
        #expect(args2.context == modifiedContext1)
    }


    @Test
    mutating func testHTTPClientRetryPolicyIntegration() async throws {
        let urlRequestLoader = MockURLRequestLoader()
        let successResponse = randomHTTPResponse()

        urlRequestLoader.dataStub = ThrowingStub(
            defaultResult: .success((successResponse.body, successResponse.httpURLResponse)),
            resultQueue: [.failure(randomError())]
        )

        let retryPolicy = TestRetryPolicy()
        retryPolicy.retryDelayStub = Stub(
            defaultReturnValue: nil,
            returnValueQueue: [Duration.seconds(1)]
        )

        let client = HTTPClient<String>(
            urlRequestLoader: urlRequestLoader,
            retryPolicy: retryPolicy
        )

        let request = randomURLRequest()
        let context = randomAlphanumericString()
        let response = try await client.load(request, context: context)

        #expect(response == successResponse)
        #expect(urlRequestLoader.dataStub.calls.count == 2)
        #expect(retryPolicy.retryDelayStub.calls.count == 2)

        let retryArgs = try #require(retryPolicy.retryDelayStub.callArguments.first)
        #expect(retryArgs.input.0 == request)
        #expect(retryArgs.input.1 == context)
    }


    @Test
    mutating func testHTTPClientCancellationDuringInterceptor() async {
        let urlRequestLoader = MockURLRequestLoader()
        urlRequestLoader.dataStub = ThrowingStub(defaultResult: .success((randomData(), randomHTTPURLResponse())))

        let interceptor = MockHTTPClientInterceptor<String>()
        interceptor.interceptPrologue = { withUnsafeCurrentTask { $0?.cancel() } }
        interceptor.nextArguments = [.init(request: randomURLRequest(), context: randomAlphanumericString())]
        interceptor.interceptStub = ThrowingStub(defaultResult: .success(randomHTTPResponse()))

        let client = HTTPClient(urlRequestLoader: urlRequestLoader, interceptors: [interceptor])

        await #expect(throws: CancellationError.self) {
            try await client.load(randomURLRequest(), context: randomAlphanumericString())
        }
    }


    @Test
    mutating func testHTTPClientURLRequestLoaderError() async {
        let urlRequestLoader = MockURLRequestLoader()
        let expectedError = randomError()
        urlRequestLoader.dataStub = ThrowingStub(defaultResult: .failure(expectedError))

        let client = HTTPClient<String>(urlRequestLoader: urlRequestLoader)

        await #expect(throws: expectedError) {
            try await client.load(randomURLRequest(), context: randomAlphanumericString())
        }
    }


    @Test
    mutating func testHTTPClientNonHTTPURLResponseError() async {
        let urlRequestLoader = MockURLRequestLoader()
        let nonHTTPResponse = URLResponse(
            url: randomURL(),
            mimeType: nil,
            expectedContentLength: randomInt(in: 100 ... 1000),
            textEncodingName: nil
        )
        urlRequestLoader.dataStub = ThrowingStub(defaultResult: .success((randomData(), nonHTTPResponse)))

        let client = HTTPClient<String>(urlRequestLoader: urlRequestLoader)

        await #expect(throws: NonHTTPURLResponseError(urlResponse: nonHTTPResponse)) {
            try await client.load(randomURLRequest(), context: randomAlphanumericString())
        }
    }


    @Test
    mutating func testHTTPClientVoidContextConvenience() async throws {
        let urlRequestLoader = MockURLRequestLoader()
        let expectedResponse = randomHTTPResponse()
        urlRequestLoader.dataStub = ThrowingStub(
            defaultResult: .success((expectedResponse.body, expectedResponse.httpURLResponse))
        )

        let client = HTTPClient<Void>(urlRequestLoader: urlRequestLoader)

        let request = randomURLRequest()
        let response = try await client.load(request)

        #expect(response == expectedResponse)
        #expect(urlRequestLoader.dataStub.callArguments == [request])
    }
}
