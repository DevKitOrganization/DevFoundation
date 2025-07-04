//
//  URLPathComponent.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/17/25.
//

import Foundation

/// A component in a URL path.
///
/// URL path components are used by ``WebServiceRequest``s to perform some basic sanitization of URLs. Instead of
/// providing an entire path, web service requests provide path components, which are joined with a `"/"` character to
/// form a full path. Path components cannot contain `"/"` characters; they will be removed upon initialization.
///
/// `URLPathComponent`s are expressible by string literal, and thus can be created with minimal syntactic overhead.
///
///     let pathComponents: [URLPathComponent] = ["path", "to", "resource"]
public struct URLPathComponent: ExpressibleByStringLiteral, Hashable, RawRepresentable, Sendable {
    /// The URL path component’s raw value.
    public let rawValue: String


    /// Creates a new URL path component with the specified raw value.
    ///
    /// Any `"/"` characters are removed from `rawValue` before storing it.
    ///
    /// - Parameter rawValue: The raw value of the URL component.
    public init(_ rawValue: String) {
        self.rawValue = rawValue.replacingOccurrences(of: "/", with: "")
    }


    public init(rawValue: String) {
        self.init(rawValue)
    }


    public init(stringLiteral: StringLiteralType) {
        self.init(stringLiteral)
    }
}
