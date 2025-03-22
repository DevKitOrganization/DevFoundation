//
//  HTTPClientResponseInterceptor.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/15/25.
//

import Foundation


/// A type that can intercept and potentially modify an HTTP response before an HTTP client returns it to a caller.
public protocol HTTPClientResponseInterceptor: Sendable {
    /// Intercepts a response from an HTTP client.
    ///
    /// This function is called by an HTTP client after it receives a response, but before it returns the response to
    /// the caller. Response interceptors can either return a potentially modified response, throw an error to abort
    /// loading, or return `nil` to cause the request to be retried. The response that the interceptor returns is most
    /// often either the one it was given or some modification of it, e.g., by adding a header or modifying the response
    /// body.
    ///
    /// - Parameters:
    ///   - response: The response being intercepted.
    ///   - client: The client that is loading the request.
    ///   - request: The request whose response is being intercepted.
    func intercept(
        _ response: HTTPResponse<Data>,
        from client: HTTPClient,
        for request: URLRequest
    ) async throws -> HTTPResponse<Data>?
}
