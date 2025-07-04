//
//  NonHTTPURLResponseError.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/16/25.
//

import Foundation

/// An error indicating that an HTTP client received a non-HTTP URL response.
public struct NonHTTPURLResponseError: Error, Hashable {
    /// The non-HTTP URL response that was received.
    public let urlResponse: URLResponse


    /// Creates a new non-HTTP URL response error.
    /// - Parameter urlResponse: The non-HTTP URL response that was received.
    public init(urlResponse: URLResponse) {
        self.urlResponse = urlResponse
    }
}
