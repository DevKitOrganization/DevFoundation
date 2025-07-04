//
//  AuthenticatorCancellationError.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/16/25.
//

import Foundation

/// An error indicating that an authenticated HTTP request was canceled by an authenticator.
public struct AuthenticatorCancellationError: Error, Hashable {
    /// Creates a new authenticator cancellation error.
    public init() {
        // Intentionally empty
    }
}
