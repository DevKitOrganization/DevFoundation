//
//  HTTPRequestAuthenticator.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/16/25.
//

import Foundation

/// A type that authenticates requests on behalf of an authenticating HTTP client.
public protocol HTTPRequestAuthenticator: Sendable {
    /// A type that contains contextual information for the authenticator.
    ///
    /// Instances of this type are provided to an authenticator when it prepares a request or evaluates a response.
    /// While various functions have arguments of this type, only the authenticator interacts with it. Thus it has no
    /// significant constraints other than sendability. The authenticator can choose any representation it needs to do
    /// its work.
    ///
    /// Use `Void` if your authenticator doesn’t need any contextual information. DevFoundation provides conveniences
    /// for authenticators with `Void` context types.
    associatedtype Context: Sendable

    /// Prepares a request with authentication information so that it can be loaded.
    ///
    /// Typical implementations will return a copy of `request` with an added authorization header or query parameter.
    ///
    /// This function is async so that credentials can be obtained, e.g., from the user, to prepare the request. For
    /// example, if an authenticator does not have credentials, it might prompt the user to log in and only prepare the
    /// request once they have done so. Returning `nil` cancels the load. This might be appropriate when, e.g., a user
    /// is unable to authenticate successfully and gives up. If a request cannot be prepared, throwing an error will
    /// abort the load and propagate the error back to the calling code.
    ///
    /// - Parameters:
    ///   - request: The request to be prepared.
    ///   - context: Contextual information about how to authenticate the request.
    ///   - previousFailures: Any previous authentication failures that occurred when attempting to load the request.
    ///     You can examine these failures when preparing the request to, e.g., invalidate authenticator state. Failures
    ///     contain errors thrown by ``throwIfResponseIndicatesAuthenticationFailure(response:request:context:)``, so
    ///     you can tailor those errors to pass information back to this one.
    /// - Returns: A request prepared with authentication information.
    func prepare(
        _ request: URLRequest,
        context: Context,
        previousFailures: [HTTPRequestAuthenticationFailure]
    ) async throws -> URLRequest?

    /// Throws an error if the response indicates that an authentication failure occurred.
    ///
    /// The default implementation of this function throws an ``UnauthorizedHTTPRequestError`` if the response has an
    /// ``HTTPStatusCode/unauthorized`` status code.
    ///
    /// - Parameters:
    ///   - response: The response to analyze.
    ///   - request: The request that was being loaded.
    ///   - context: The contextual information that was used to prepare the reqwuest.
    func throwIfResponseIndicatesAuthenticationFailure(
        response: HTTPResponse<Data>,
        request: URLRequest,
        context: Context
    ) throws
}


extension HTTPRequestAuthenticator {
    public func throwIfResponseIndicatesAuthenticationFailure(
        response: HTTPResponse<Data>,
        request: URLRequest,
        context: Context
    ) throws {
        if response.statusCode == .unauthorized {
            throw UnauthorizedHTTPRequestError()
        }
    }
}
