//
//  HTTPClientRequestInterceptor.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/15/25.
//

import Foundation

/// A type that can intercept and potentially modify a request before an HTTP client loads it.
public protocol HTTPClientRequestInterceptor: Sendable {
    /// Intercepts a request from an HTTP client.
    ///
    /// This function is called by an HTTP client before it loads a request. Request interceptors can either return a
    /// request to load or throw an error to abort loading. The request that the interceptor returns is most often
    /// either the one it was given or some modification of it, e.g., by adding a header or query item.
    ///
    /// - Parameters:
    ///   - request: The request being intercepted.
    ///   - client: The client that is loading the request.
    func intercept(_ request: URLRequest, from client: HTTPClient) async throws -> URLRequest
}
