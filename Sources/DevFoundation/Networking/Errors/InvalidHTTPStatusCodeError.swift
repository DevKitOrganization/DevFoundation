//
//  InvalidHTTPStatusCodeError.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/19/25.
//

import Foundation


/// An error indicating that an HTTP response was received that had an invalid status code.
public struct InvalidHTTPStatusCodeError: Error, Hashable {
    /// The HTTP URL response that was received.
    public let httpURLResponse: HTTPURLResponse


    /// Creates a new invalid HTTP status code error for the specified response.
    ///
    /// - Parameter httpURLResponse: The HTTP URL response that was received.
    public init(httpURLResponse: HTTPURLResponse) {
        self.httpURLResponse = httpURLResponse
    }


    /// The invalid status code.
    public var statusCode: HTTPStatusCode {
        return httpURLResponse.httpStatusCode
    }
}
