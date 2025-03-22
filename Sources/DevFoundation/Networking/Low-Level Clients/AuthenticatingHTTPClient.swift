//
//  AuthenticatingHTTPClient.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/16/25.
//

import Foundation


/// An HTTP client that uses an authenticator to authenticate requests.
///
/// Authenticating HTTP clients use ``HTTPRequestAuthenticator``s to prepare their outgoing requests with authentication
/// information and evaluate whether a response indicates an authentication failure.
///
/// Under the covers, authenticating HTTP clients use ``HTTPClient``s to load their requests, and thus have a similar
/// interface.
public final class AuthenticatingHTTPClient<Authenticator>: Sendable where Authenticator: HTTPRequestAuthenticator {
    /// The authenticator that the client uses to authenticate its requests.
    public let authenticator: Authenticator

    /// The HTTP client that the instance uses to load HTTP requests.
    private let httpClient: HTTPClient


    /// Creates a new authenticating HTTP client.
    ///
    /// - Parameters:
    ///   - urlRequestLoader: The client’s URL request loader.
    ///   - authenticator: The authenticator that the client uses to authenticate its requests.
    ///   - requestInterceptors: The client’s request interceptors. By default, a client has no request interceptors.
    ///   - responseInterceptors: The client’s response interceptors. By default, a client has no response interceptors.
    public init(
        urlRequestLoader: any URLRequestLoader,
        authenticator: Authenticator,
        requestInterceptors: [any HTTPClientRequestInterceptor] = [],
        responseInterceptors: [any HTTPClientResponseInterceptor] = []
    ) {
        self.authenticator = authenticator
        self.httpClient = HTTPClient(
            urlRequestLoader: urlRequestLoader,
            requestInterceptors: requestInterceptors,
            responseInterceptors: responseInterceptors
        )
    }


    /// The client’s underlying URL request loader.
    public var urlRequestLoader: any URLRequestLoader {
        return httpClient.urlRequestLoader
    }


    /// The client’s request interceptors.
    public var requestInterceptors: [any HTTPClientRequestInterceptor] {
        return httpClient.requestInterceptors
    }


    /// The client’s response interceptors.
    public var responseInterceptors: [any HTTPClientResponseInterceptor] {
        return httpClient.responseInterceptors
    }


    /// Loads the specified unauthenticated URL request and asynchronously returns its HTTP response.
    ///
    /// See ``HTTPClient/load(_:)`` for more information.
    ///
    /// - Parameter urlRequest: The URL request to load.
    public func load(_ urlRequest: URLRequest) async throws -> HTTPResponse<Data> {
        return try await httpClient.load(urlRequest)
    }


    /// Loads the specified authenticated URL request and asynchronously returns its HTTP response.
    ///
    /// Before loading the request, the client calls ``HTTPRequestAuthenticator/prepare(_:context:previousFailures:)``
    /// on its authenticator to prepare it with authentication information. If the authenticator throws an error, this
    /// function propagates it to the caller. If it returns `nil`, this function throws an
    /// ``AuthenticatorCancellationError``. Otherwise, the client loads the request returned by the authenticator using
    /// ``load(_:)``.
    ///
    /// If the load completes successfully, the client calls
    /// ``HTTPRequestAuthenticator/throwIfResponseIndicatesAuthenticationFailure(response:request:context:)`` on its
    /// authenticator. If that function does not throw, the response is returned to the caller. Otherwise, the process
    /// repeats until the authenticator cancels or aborts the request or the response does not indicate an
    /// authentication failure.
    public func load(
        _ urlRequest: URLRequest,
        authenticatorContext: Authenticator.Context
    ) async throws -> HTTPResponse<Data> {
        return try await load(urlRequest, authenticatorContext: authenticatorContext, previousFailures: [])
    }


    /// A recursive function that loads the specified authenticated URL request and asynchronously returns it HTTP
    /// response.
    ///
    /// If the authenticator finds an authentication failure in the response, this function calls itself recursively
    /// after appending the latest failure to `previousFailures`.
    ///
    /// - Parameters:
    ///   - urlRequest: The URL request to load.
    ///   - authenticatorContext: Contextual information that the client’s authenticator can use to prepare the request.
    ///   - previousFailures: Any previous authentication failures that occurred when attempting to load the request.
    private func load(
        _ urlRequest: URLRequest,
        authenticatorContext: Authenticator.Context,
        previousFailures: [HTTPRequestAuthenticationFailure]
    ) async throws -> HTTPResponse<Data> {
        // Prepare the request, throwing a cancellation error if the authenticator returns nil
        guard let preparedRequest = try await authenticator.prepare(
            urlRequest,
            context: authenticatorContext,
            previousFailures: previousFailures
        ) else {
            throw AuthenticatorCancellationError()
        }

        // Load the prepared request
        try Task.checkCancellation()
        let response = try await load(preparedRequest)

        do {
            // Check if the response indicates an authentication failure. If not, return the response
            try Task.checkCancellation()
            try authenticator.throwIfResponseIndicatesAuthenticationFailure(
                response: response,
                request: urlRequest,
                context: authenticatorContext
            )
            return response
        } catch {
            // Otherwise recursively call this function with the new failure appended to previousFailures
            let failure = HTTPRequestAuthenticationFailure(
                preparedRequest: preparedRequest,
                response: response,
                error: error
            )

            try Task.checkCancellation()
            return try await load(
                urlRequest,
                authenticatorContext: authenticatorContext,
                previousFailures: previousFailures + [failure]
            )
        }
    }
}
