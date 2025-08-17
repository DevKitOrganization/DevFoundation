//
//  HTTPClientInterceptor.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/16/25.
//

import Foundation

/// A type that intercepts requests and responses for HTTP clients.
///
/// Interceptors allow you to inspect and modify requests and responses. Requests are intercepted before they are passed
/// to a URL request loader, and responses are intercepted after they have been received from the loader. They are
/// typically used for cross-cutting concerns like authentication, logging, and tracing.
public protocol HTTPClientInterceptor<RequestContext>: Sendable {
    /// The type of request context that the interceptor can work with.
    associatedtype RequestContext: Sendable

    /// Intercept a URL request.
    ///
    /// - Parameters:
    ///   - request: The request to intercept.
    ///   - context: Additional context about the request. This type can be used to make decisions about how to perform
    ///     interception.
    ///   - next: A closure to call to pass the request and context to the next interceptor in the chain.
    func intercept(
        request: URLRequest,
        context: RequestContext,
        next: (
            _ request: URLRequest,
            _ context: RequestContext
        ) async throws -> HTTPResponse<Data>
    ) async throws -> HTTPResponse<Data>
}
