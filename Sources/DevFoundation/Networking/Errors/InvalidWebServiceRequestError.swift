//
//  InvalidWebServiceRequestError.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/17/25.
//

import Foundation


/// An error indicating that a web service request was invalid.
///
/// A web service request might be invalid because it couldn’t be used to construct a valid URL request or its HTTP body
/// could not be constructed successfully.
public struct InvalidWebServiceRequestError: Error {
    /// A description of the error to aid in debugging.
    public let debugDescription: String

    /// The underlying error which caused this error, if any.
    public let underlyingError: (any Error)?

    
    /// Creates a new invalid web service request error with the specified debug description and underyling error.
    ///
    /// - Parameters:
    ///   - debugDescription: A description of the error to aid in debugging.
    ///   - underlyingError: The underlying error which caused this error, if any. Defaults to `nil`.
    public init(debugDescription: String, underlyingError: (any Error)? = nil) {
        self.debugDescription = debugDescription
        self.underlyingError = underlyingError
    }
}
