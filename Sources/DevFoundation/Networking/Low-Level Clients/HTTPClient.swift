//
//  HTTPClient.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/15/25.
//

import Foundation

/// A simple client for loading URL requests and returning an HTTP response.
public final class HTTPClient: Sendable {
    /// The client’s underlying URL request loader.
    public let urlRequestLoader: any URLRequestLoader

    /// The client’s request interceptors.
    public let requestInterceptors: [any HTTPClientRequestInterceptor]

    /// The client’s response interceptors.
    public let responseInterceptors: [any HTTPClientResponseInterceptor]


    /// Creates a new HTTP client.
    /// - Parameters:
    ///   - urlRequestLoader: The client’s underlying URL request loader.
    ///   - requestInterceptors: The client’s request interceptors. By default, a client has no request interceptors.
    ///   - responseInterceptors: The client’s response interceptors. By default, a client has no response interceptors.
    public init(
        urlRequestLoader: any URLRequestLoader,
        requestInterceptors: [any HTTPClientRequestInterceptor] = [],
        responseInterceptors: [any HTTPClientResponseInterceptor] = []
    ) {
        self.urlRequestLoader = urlRequestLoader
        self.requestInterceptors = requestInterceptors
        self.responseInterceptors = responseInterceptors
    }


    /// Loads the specified URL request and asynchronously returns its HTTP response.
    ///
    /// Before loading the request, the client first allows its request interceptors the option to return it unchanged,
    /// modify it, or throw an error and abort. The first interceptor is passed `urlRequest`, and each successive
    /// interceptor is passed the URL request returned by the previous interceptor. If one of the request interceptors
    /// throws an error, loading is aborted and the error is thrown. When all request interceptors have completed
    /// without throwing an error, the client loads the final resultant request.
    ///
    /// When the client receives a response to the request, it passes it to the client’s response interceptors, which
    /// each have the option to return it unchanged, modify it, throw an error, or indicate that the entire load should
    /// be retried. The first interceptor is passed the response from the load, and each successive one is passed the
    /// response returned by the previous interceptor. If one of the response interceptors throws an error, loading is
    /// aborted and the error is thrown. If an interceptor returns `nil`, the original URL request is loaded again. When
    /// all response interceptors have completed without throwing an error or returning `nil`, the resultant response is
    /// returned to the caller.
    ///
    /// - Parameter urlRequest: The URL request to load must be an HTTP or HTTPS URL request.
    public func load(_ urlRequest: URLRequest) async throws -> HTTPResponse<Data> {
        // Intercept the request
        var interceptedRequest = urlRequest
        for requestInterceptor in requestInterceptors {
            interceptedRequest = try await requestInterceptor.intercept(interceptedRequest, from: self)
            try Task.checkCancellation()
        }

        // Load the intercepted request, throwing if the response isn’t an HTTPURLResponse
        let (data, urlResponse) = try await urlRequestLoader.data(for: interceptedRequest)
        try Task.checkCancellation()
        guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
            throw NonHTTPURLResponseError(urlResponse: urlResponse)
        }

        // Intercept the response
        var interceptedResponse = HTTPResponse(httpURLResponse: httpURLResponse, body: data)
        for responseInterceptor in responseInterceptors {
            // If the interceptor returns nil, load the original request
            guard
                let nextResponse = try await responseInterceptor.intercept(
                    interceptedResponse,
                    from: self,
                    for: interceptedRequest
                )
            else {
                try Task.checkCancellation()
                return try await load(urlRequest)
            }

            try Task.checkCancellation()
            interceptedResponse = nextResponse
        }

        return interceptedResponse
    }
}
