//
//  HTTPClient.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/15/25.
//

import Foundation

/// A client for loading HTTP requests.
///
/// Each client has an array of interceptors and a retry policy. Interceptors process requests before they’re loaded and
/// responses before they’re returned. The retry policy indicates if a request should be retried, and if so, how much
/// time should elapse before retrying. When a request is made, an instance of the client’s `RequestContext` type is
/// passed alongside the request to the interceptors and retry policy. This type can be used to make decisions about
/// how to intercept the request/response or whether a retry should occur. For example, if we had a logging interceptor,
/// we could update our `RequestContext` to include information about whether the request should be logged or not.
///
/// We can use all of these features to implement complex behaviors. For example,, to implement authentication, we could
/// use the request context, an interceptor, and a retry policy.
///
///   1. Our client’s `RequestContext` type could include the authentication level required, e.g., `anonymous` or
///     `user`.
///   2. Our interceptor could work with an `Authenticator` type to get the correct bearer token for the authentication
///     level and attach it to the request via an ``HTTPHeaderField/authorization`` header.
///   3. If the HTTP response has an ``HTTPStatusCode/unauthorized`` status code, the interceptor could tell its
///     `Authenticator` to invalidate its token.
///   4. Our retry policy could automatically retry requests that failed with an `unauthorized` status code.
///
public final class HTTPClient<RequestContext>: Sendable where RequestContext: Sendable {
    /// The client’s underlying URL request loader.
    public let urlRequestLoader: any URLRequestLoader

    /// The client’s interceptors.
    public let interceptors: [any HTTPClientInterceptor<RequestContext>]

    /// The client’s retry policy.
    public let retryPolicy: (any RetryPolicy<(URLRequest, RequestContext), Result<HTTPResponse<Data>, any Error>>)?


    /// Creates a new HTTP client.
    ///
    /// - Parameters:
    ///   - urlRequestLoader: The client’s underlying URL request loader.
    ///   - interceptors: The client’s interceptors. Empty by default.
    ///   - retryPolicy: The client’s retry policy. `nil` by default.
    public init(
        urlRequestLoader: any URLRequestLoader,
        interceptors: [any HTTPClientInterceptor<RequestContext>] = [],
        retryPolicy: (any RetryPolicy<(URLRequest, RequestContext), Result<HTTPResponse<Data>, any Error>>)? = nil
    ) {
        self.urlRequestLoader = urlRequestLoader
        self.interceptors = interceptors
        self.retryPolicy = retryPolicy
    }


    /// Loads the specified URL request and asynchronously returns its HTTP response.
    ///
    /// Before loading the request, the client passes the request to its interceptors, which can modify the request or
    /// abort. Once all interceptors have finished processing the request, it is loaded, and the result is passed back
    /// to the interceptors (from last to first) so that they can process it as needed.
    ///
    /// Once all interceptors are done processing the response, a HTTP client consults its retry policy to determine if
    /// the request should be retried. If not, the response is returned to the caller. Otherwise, the process repeats
    /// until the retry policy indicates that no more retries should occur.
    ///
    /// - Parameters:
    ///   - urlRequest: The URL request to load. Must be an HTTP or HTTPS URL request.
    ///   - context: The request context that is passed to the client’s interceptors and retry policy to aid in their
    ///     execution.
    public func load(_ urlRequest: URLRequest, context: RequestContext) async throws -> HTTPResponse<Data> {
        return try await load(urlRequest, context: context, attemptCount: 1, initialDelay: .zero)
    }


    /// Loads the specified request, retrying as necessary.
    ///
    /// This function calls itself recursively to retry requests.
    ///
    /// - Parameters:
    ///   - urlRequest: The URL request to load.
    ///   - context: The request context that is passed to the client’s interceptors and retry policy to aid in their
    ///     execution.
    ///   - attemptCount: The number of times (including this one) that an attempt has been made to load this request.
    ///     This should be `1` when the request is initiated.
    ///   - initialDelay: The initial delay that should occur loading the request. This should be `.zero` when the
    ///     request is initiated.
    private func load(
        _ urlRequest: URLRequest,
        context: RequestContext,
        attemptCount: Int,
        initialDelay: Duration
    ) async throws -> HTTPResponse<Data> {
        if initialDelay != .zero {
            try Task.checkCancellation()
            try await Task.sleep(for: initialDelay)
        }

        let result = await Result {
            try await load(urlRequest, context: context, interceptorIndex: 0)
        }

        guard
            let retryPolicy,
            let delay = retryPolicy.retryDelay(
                forInput: (urlRequest, context),
                output: result,
                attemptCount: attemptCount,
                previousDelay: initialDelay
            )
        else {
            return try result.get()
        }

        return try await load(urlRequest, context: context, attemptCount: attemptCount + 1, initialDelay: delay)
    }


    /// Loads the specified request by passing it to an interceptor at the specified index.
    ///
    /// This function calls itself recursively to pass the request to the client’s interceptors.
    ///
    /// - Parameters:
    ///   - urlRequest: The URL request to load.
    ///   - context: The request context that is passed to the client’s interceptors and retry policy to aid in their
    ///     execution.
    ///   - interceptorIndex: The index of the interceptor that is being passed the request. When `interceptorIndex` is
    ///     beyond the bounds of the instance’s `interceptors` array, the function loads the request using
    ///     `urlRequestLoader` and returns the response.
    private func load(
        _ urlRequest: URLRequest,
        context: RequestContext,
        interceptorIndex: Int
    ) async throws -> HTTPResponse<Data> {
        try Task.checkCancellation()

        // If we’re out of interceptors, load the data
        guard interceptorIndex < interceptors.endIndex else {
            let (data, urlResponse) = try await urlRequestLoader.data(for: urlRequest)
            try Task.checkCancellation()
            guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
                throw NonHTTPURLResponseError(urlResponse: urlResponse)
            }

            return HTTPResponse(httpURLResponse: httpURLResponse, body: data)
        }

        // Otherwise, pass the interceptor our data and call the next one
        return try await interceptors[interceptorIndex].intercept(
            request: urlRequest,
            context: context
        ) { (request, context) in
            return try await load(request, context: context, interceptorIndex: interceptorIndex + 1)
        }
    }
}


extension HTTPClient<Void> {
    /// Loads the specified URL request and asynchronously returns its HTTP response.
    ///
    /// - Parameter urlRequest: The URL request to load.
    public func load(_ urlRequest: URLRequest) async throws -> HTTPResponse<Data> {
        return try await load(urlRequest, context: ())
    }
}
