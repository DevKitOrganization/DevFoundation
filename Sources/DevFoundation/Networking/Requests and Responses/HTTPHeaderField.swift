//
//  HTTPHeaderField.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/15/25.
//

import Foundation

/// An HTTP header field.
///
/// DevFoundation provides a few common header fields out of the box, but as with all typed extensible enums, you can
/// add more via an extension.
public struct HTTPHeaderField: TypedExtensibleEnum {
    public let rawValue: String


    /// Creates a new HTTP header field.
    ///
    /// The raw value is lowercased before being stored.
    ///
    /// - Parameter rawValue: The raw value to use for the HTTP header field.
    public init(_ rawValue: String) {
        self.rawValue = rawValue.lowercased()
    }
}


extension HTTPHeaderField {
    /// The Accept HTTP header field, `accept`.
    public static let accept = HTTPHeaderField("accept")

    /// The Accept Language HTTP header field, `accept-language`.
    public static let acceptLanguage = HTTPHeaderField("accept-language")

    /// The Authorization HTTP header field, `authorization`.
    public static let authorization = HTTPHeaderField("authorization")

    /// The Content Type HTTP header field, `content-type`.
    public static let contentType = HTTPHeaderField("content-type")

    /// The User Agent HTTP header field, `user-agent`.
    public static let userAgent = HTTPHeaderField("user-agent")
}


extension URLRequest {
    /// Returns the value for the specified HTTP header field.
    ///
    /// - Parameter field: The HTTP header field.
    /// - Returns: The value associated with the header field, or `nil` if there is no such value.
    public func httpHeaderValue(for field: HTTPHeaderField) -> String? {
        return value(forHTTPHeaderField: field.rawValue)
    }


    /// Adds a value to the specified HTTP header field.
    ///
    /// The value is added to the field incrementally. That is, if a value was previously set for the specified field,
    /// the supplied value is appended to the existing value using the appropriate field delimiter (a comma).
    ///
    /// - Parameters:
    ///   - value: The value for the HTTP header field.
    ///   - field: The HTTP header field.
    public mutating func addHTTPHeaderValue(_ value: String, for field: HTTPHeaderField) {
        addValue(value, forHTTPHeaderField: field.rawValue)
    }


    /// Sets a value to the specified HTTP header field.
    ///
    /// - Parameters:
    ///   - value: The value for the HTTP header field.
    ///   - field: The HTTP header field.
    public mutating func setHTTPHeaderValue(_ value: String?, for field: HTTPHeaderField) {
        setValue(value, forHTTPHeaderField: field.rawValue)
    }
}


extension HTTPURLResponse {
    /// Returns the value for the specified HTTP header field.
    ///
    /// - Parameter field: The HTTP header field.
    /// - Returns: The value associated with the header field, or `nil` if there is no such value.
    public func httpHeaderValue(for field: HTTPHeaderField) -> String? {
        return value(forHTTPHeaderField: field.rawValue)
    }
}
