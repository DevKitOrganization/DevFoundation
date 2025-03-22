//
//  AuthenticatingHTTPClientTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/16/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing


struct AuthenticatingHTTPClientTests: RandomValueGenerating {
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

        let client = AuthenticatingHTTPClient(
            urlRequestLoader: urlRequestLoader,
            authenticator: authenticator,
            requestInterceptors: requestInterceptors,
            responseInterceptors: responseInterceptors
        )

        #expect(client.urlRequestLoader as? MockURLRequestLoader === urlRequestLoader)
        #expect(client.authenticator === authenticator)
        #expect(client.requestInterceptors as? [MockHTTPClientRequestInterceptor] == requestInterceptors)
        #expect(client.responseInterceptors as? [MockHTTPClientResponseInterceptor] == responseInterceptors)
    }


    @Test
    mutating func unauthenticatedLoadThrowsWhenClientThrows() async {
        // Set up our URL request loader to throw an error
        let expectedError = randomError()
        let urlRequestLoader = MockURLRequestLoader()
        urlRequestLoader.dataStub = .init(defaultResult: .failure(expectedError))

        // Set up our client
        let client = AuthenticatingHTTPClient(
            urlRequestLoader: urlRequestLoader,
            authenticator: MockHTTPRequestAuthenticator()
        )

        // Load the request and expect an error
        let request = randomURLRequest()
        await #expect(throws: expectedError) {
            try await client.load(request)
        }

        #expect(urlRequestLoader.dataStub.callArguments == [request])
    }


    @Test
    mutating func unauthenticatedLoadReturnsWhenClientReturns() async throws {
        // Set up our URL request loader to throw an error
        let expectedResponse = randomHTTPResponse()
        let urlRequestLoader = MockURLRequestLoader()
        urlRequestLoader.dataStub = .init(
            defaultResult: .success((expectedResponse.body, expectedResponse.httpURLResponse))
        )

        // Set up our client
        let client = AuthenticatingHTTPClient(
            urlRequestLoader: urlRequestLoader,
            authenticator: MockHTTPRequestAuthenticator()
        )

        // Load the request and expect an error
        let request = randomURLRequest()
        let response = try await client.load(request)
        #expect(response == expectedResponse)
    }


    @Test
    mutating func authenticatedLoadThrowsWhenPrepareThrows() async throws {
        // Set up our authenticator to throw an error during prepare
        let authenticator = MockHTTPRequestAuthenticator()
        let expectedError = randomError()
        authenticator.prepareStub = .init(defaultResult: .failure(expectedError))

        // Set up our client
        let client = AuthenticatingHTTPClient(urlRequestLoader: MockURLRequestLoader(), authenticator: authenticator)

        // Load the request and expect the error that the authenticator threw to be propagated
        let request = randomURLRequest()
        let context = randomAuthenticatorContext()
        await #expect(throws: expectedError) {
            try await client.load(request, authenticatorContext: context)
        }

        // Verify prepare was only called once
        #expect(authenticator.prepareStub.calls.count == 1)
        let prepareArguments = try #require(authenticator.prepareStub.callArguments.first)
        #expect(prepareArguments.request == request)
        #expect(prepareArguments.context == context)
        #expect(prepareArguments.previousFailures.isEmpty)
    }


    @Test
    mutating func authenticatedLoadThrowsCancellationErrorWhenPrepareReturnsNil() async {
        // Set up our authenticator to return nil from prepare
        let authenticator = MockHTTPRequestAuthenticator()
        authenticator.prepareStub = .init(defaultResult: .success(nil))

        // Set up our client
        let client = AuthenticatingHTTPClient(urlRequestLoader: MockURLRequestLoader(), authenticator: authenticator)

        // Load the request and expect an authenticator cancellation error
        let request = randomURLRequest()
        let context = randomAuthenticatorContext()
        await #expect(throws: AuthenticatorCancellationError.self) {
            try await client.load(request, authenticatorContext: context)
        }
    }


    @Test
    mutating func authenticatedLoadCancelsWhenCanceledDuringPrepare() async {
        // Set up our authenticator to cancel during prepare
        let authenticator = MockHTTPRequestAuthenticator()
        authenticator.prepareStub = .init(defaultResult: .success(randomURLRequest()))
        authenticator.preparePrologue = { withUnsafeCurrentTask { $0?.cancel() } }

        // Set up our client
        let client = AuthenticatingHTTPClient(urlRequestLoader: MockURLRequestLoader(), authenticator: authenticator)

        // Load the request and expect a cancellation error
        await #expect(throws: CancellationError.self) {
            try await client.load(randomURLRequest(), authenticatorContext: randomAuthenticatorContext())
        }
    }


    @Test
    mutating func authenticatedLoadThrowsErrorWhenHTTPClientThrowsError() async {
        // Set up our authenticator to succeessfully prepare
        let authenticator = MockHTTPRequestAuthenticator()
        let preparedRequest = randomURLRequest()
        authenticator.prepareStub = .init(defaultResult: .success(preparedRequest))

        // Set up our URL request loader to throw an error
        let urlRequestLoader = MockURLRequestLoader()
        let expectedError = randomError()
        urlRequestLoader.dataStub = .init(defaultResult: .failure(expectedError))

        // Set up our client
        let client = AuthenticatingHTTPClient(urlRequestLoader: urlRequestLoader, authenticator: authenticator)

        // Load the request and expect the HTTP client’s error to be propagated
        await #expect(throws: expectedError) {
            try await client.load(randomURLRequest(), authenticatorContext: randomAuthenticatorContext())
        }

        // Verify that the URL request loader loaded the prepared URL
        #expect(urlRequestLoader.dataStub.callArguments == [preparedRequest])
    }


    @Test
    mutating func authenticatedLoadReturnsWhenAuthenticatorDoesNotFindAuthenticationFailure() async throws {
        // Set up our authenticator to successfully prepare and not find an authentication failure
        let authenticator = MockHTTPRequestAuthenticator()
        let preparedRequest = randomURLRequest()
        authenticator.prepareStub = .init(defaultResult: .success(preparedRequest))
        authenticator.throwStub = .init(defaultError: nil)

        // Set up our URL request loader to succeed
        let urlRequestLoader = MockURLRequestLoader()
        let expectedResponse = randomHTTPResponse()
        urlRequestLoader.dataStub = .init(
            defaultResult: .success((expectedResponse.body, expectedResponse.httpURLResponse))
        )

        // Set up our client
        let client = AuthenticatingHTTPClient(urlRequestLoader: urlRequestLoader, authenticator: authenticator)

        // Load the request and expect the HTTP client response to be returned
        let request = randomURLRequest()
        let context = randomAuthenticatorContext()
        let response = try await client.load(request, authenticatorContext: context)
        #expect(response == expectedResponse)

        // Verify that the authenticator’s throw function got the right arguments
        #expect(authenticator.throwStub.callArguments.count == 1)
        let throwArguments = try #require(authenticator.throwStub.callArguments.first)
        #expect(throwArguments.response == response)
        #expect(throwArguments.request == request)
        #expect(throwArguments.context == context)
    }


    @Test
    mutating func authenticatedLoadRetriesRequestWhenAuthenticatorFindsAuthenticationFailure() async throws {
        // Set up our authenticator to successfully prepare twice, and find an authentication failure in the first
        // response
        let authenticator = MockHTTPRequestAuthenticator()
        let preparedRequest1 = randomURLRequest()
        let preparedRequest2 = randomURLRequest()
        authenticator.prepareStub = .init(
            defaultResult: .success(preparedRequest2),
            resultQueue: [.success(preparedRequest1)]
        )
        let expectedError = randomError()
        authenticator.throwStub = .init(defaultError: nil, errorQueue: [expectedError])

        // Set up our URL request loader to succeed twice
        let urlRequestLoader = MockURLRequestLoader()
        let expectedResponse1 = randomHTTPResponse()
        let expectedResponse2 = randomHTTPResponse()
        urlRequestLoader.dataStub = .init(
            defaultResult: .success((expectedResponse2.body, expectedResponse2.httpURLResponse)),
            resultQueue: [.success((expectedResponse1.body, expectedResponse1.httpURLResponse))]
        )

        // Set up our client
        let client = AuthenticatingHTTPClient(urlRequestLoader: urlRequestLoader, authenticator: authenticator)

        // Load the request and expect to get the second response
        let request = randomURLRequest()
        let context = randomAuthenticatorContext()
        let response = try await client.load(request, authenticatorContext: context)
        #expect(response == expectedResponse2)

        // Verify that the authenticator’s prepare function got the right arguments
        #expect(authenticator.prepareStub.callArguments.count == 2)
        let prepareArguments1 = try #require(authenticator.prepareStub.callArguments.first)
        #expect(prepareArguments1.request == request)
        #expect(prepareArguments1.context == context)
        #expect(prepareArguments1.previousFailures.isEmpty)

        let prepareArguments2 = try #require(authenticator.prepareStub.callArguments.last)
        #expect(prepareArguments2.request == request)
        #expect(prepareArguments2.context == context)
        #expect(prepareArguments2.previousFailures.count == 1)

        let previousFailure = try #require(prepareArguments2.previousFailures.first)
        #expect(previousFailure.preparedRequest == preparedRequest1)
        #expect(previousFailure.response == expectedResponse1)
        #expect(previousFailure.error as? MockError == expectedError)

        // Verify that the URL request loader got the right requests
        #expect(urlRequestLoader.dataStub.callArguments == [preparedRequest1, preparedRequest2])

        // Verify that the authenticator’s throw function got the right arguments
        #expect(authenticator.throwStub.callArguments.count == 2)
        for (args, response) in zip(authenticator.throwStub.callArguments, [expectedResponse1, expectedResponse2]) {
            #expect(args.response == response)
            #expect(args.request == request)
            #expect(args.context == context)
        }
    }


    @Test
    mutating func authenticatedLoadCancelsBeforeRetryWhenCanceledDuringThrowIfAuthenticationFailure() async throws {
        // Set up our authenticator to prepare successfully, find an authentication failure in the response, and cancel
        // while finding the authentication failure
        let authenticator = MockHTTPRequestAuthenticator()
        let preparedRequest = randomURLRequest()
        authenticator.prepareStub = .init(defaultResult: .success(preparedRequest))
        authenticator.throwStub = .init(defaultError: randomError())
        authenticator.throwPrologue = { withUnsafeCurrentTask { $0?.cancel() } }

        // Set up our URL request loader to succeed
        let urlRequestLoader = MockURLRequestLoader()
        let expectedResponse = randomHTTPResponse()
        urlRequestLoader.dataStub = .init(
            defaultResult: .success((expectedResponse.body, expectedResponse.httpURLResponse))
        )

        // Set up our client
        let client = AuthenticatingHTTPClient(urlRequestLoader: urlRequestLoader, authenticator: authenticator)

        // Load the request and expect a cancellation error
        await #expect(throws: CancellationError.self) {
            try await client.load(randomURLRequest(), authenticatorContext: randomAuthenticatorContext())
        }

        // Verify that the authenticator’s prepare and throw functions are only called once
        #expect(authenticator.prepareStub.callArguments.count == 1)
        #expect(authenticator.throwStub.callArguments.count == 1)
    }
}
