//
//  UnauthorizedHTTPRequestError.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/16/25.
//

import Foundation

/// An error indicating that an HTTP request failed because it was unauthorized.
///
/// An error of this type is thrown by
/// ``HTTPRequestAuthenticator/throwIfResponseIndicatesAuthenticationFailure(response:request:context:)`` if the
/// response’s status code is ``HTTPStatusCode/unauthorized``. If you provide your own implementation of this function,
/// you can use it as well, although it provides no actual information.
public struct UnauthorizedHTTPRequestError: Error, Hashable {
    /// Creates a new unauthorized HTTP request error.
    public init() {
        // Intentionally empty
    }
}
