//
//  HTTPRequestAuthenticationFailure.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/16/25.
//

import Foundation


/// Information about an HTTP request authentication failure.
///
/// Authentication failures are relevant if you are creating an ``HTTPRequestAuthenticator``, but are otherwise of
/// little utility.
public struct HTTPRequestAuthenticationFailure: Sendable {
    /// The prepared request whose response contained an authentication error.
    public let preparedRequest: URLRequest
    
    /// The response to the prepared request.
    public let response: HTTPResponse<Data>

    /// The authentication error that occurred.
    public let error: any Error

    
    /// Creates a new HTTP request authentication failure with the specified prepared request, response, and error.
    /// - Parameters:
    ///   - preparedRequest: The prepared request whose response contained an authentication error.
    ///   - response: The response to the prepared request.
    ///   - error: The authentication error that occurred.
    public init(preparedRequest: URLRequest, response: HTTPResponse<Data>, error: any Error) {
        self.preparedRequest = preparedRequest
        self.response = response
        self.error = error
    }
}
