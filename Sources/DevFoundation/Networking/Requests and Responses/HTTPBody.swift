//
//  HTTPBody.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/13/25.
//

import Foundation

/// The body of an HTTP request, which pairs the body’s data with its content type.
public struct HTTPBody: Hashable, Sendable {
    /// The body’s content type.
    public var contentType: MediaType

    /// The body’s data.
    public var data: Data


    /// Creates a new HTTP body with the specified content type and data.
    /// - Parameters:
    ///   - contentType: The body’s content type.
    ///   - data: The body’s data.
    public init(contentType: MediaType, data: Data) {
        self.contentType = contentType
        self.data = data
    }
}
