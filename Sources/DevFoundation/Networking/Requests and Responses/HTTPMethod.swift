//
//  HTTPMethod.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/13/25.
//

import Foundation

/// An HTTP method.
///
/// DevFoundation provides constants for ``get``, ``post``, ``put``, ``patch``, and ``delete``. Other HTTP methods can
/// be added with an extension.
public struct HTTPMethod: TypedExtensibleEnum {
    public let rawValue: String


    /// Creates a new HTTP method with the specified raw value.
    ///
    /// The raw value is uppercased before being stored.
    ///
    /// - Parameter rawValue: The HTTP method’s raw value.
    public init(_ rawValue: String) {
        self.rawValue = rawValue.uppercased()
    }
}


extension HTTPMethod {
    /// The HTTP DELETE method.
    public static let delete = HTTPMethod("DELETE")

    /// The HTTP GET method.
    public static let get = HTTPMethod("GET")

    /// The HTTP PATCH method.
    public static let patch = HTTPMethod("PATCH")

    /// The HTTP POST method.
    public static let post = HTTPMethod("POST")

    /// The HTTP PUT method.
    public static let put = HTTPMethod("PUT")
}
