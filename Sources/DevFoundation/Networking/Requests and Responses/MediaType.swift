//
//  MediaType.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/13/25.
//

import Foundation
import UniformTypeIdentifiers


/// A typed extensible enum for representing IANA media types.
///
/// Media types are often referred to as MIME types. DevFoundation includes a few common media types like ``json`` and
/// ``octetStream``. Other media types can be added with an extension.
public struct MediaType: TypedExtensibleEnum {
    public let rawValue: String

    
    /// Creates a new media type with the specified raw value.
    ///
    /// The raw value is lowercased before being stored.
    ///
    /// - Parameter rawValue: The media type string.
    public init(_ rawValue: String) {
        self.rawValue = rawValue.lowercased()
    }


    /// The uniform type identifer that corresponds to the media type.
    ///
    /// This function may return a dynamic uniform type identifier if the media type is unknown.
    public var uniformTypeIdentifier: UTType? {
        return UTType(mimeType: rawValue)
    }
}


extension MediaType {
    /// The media type for JSON data, `"application/json"`.
    public static let json = MediaType("application/json")

    /// The media type for arbitrary binary data, `"application/octet-stream"`.
    public static let octetStream = MediaType("application/octet-stream")

    /// The media type for plain text, `"text/plain"`.
    public static let plainText = MediaType("text/plain")

    /// The media type for URL-encoded HTML form data, `"application/x-www-form-urlencoded"`.
    public static let wwwFormURLEncoded = MediaType("application/x-www-form-urlencoded")
}
