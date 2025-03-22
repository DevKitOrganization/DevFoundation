//
//  HTTPHeaderItem.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/15/25.
//

import Foundation


/// An HTTP header item, including its field and value.
public struct HTTPHeaderItem: Hashable, Sendable {
    /// The HTTP header item’s field.
    public var field: HTTPHeaderField

    /// The HTTP header item’s value.
    public var value: String

    
    /// Creates a new HTTP header item with the specified field and value.
    /// - Parameters:
    ///   - field: The HTTP header item’s field.
    ///   - value: The HTTP header item’s value.
    public init(field: HTTPHeaderField, value: String) {
        self.field = field
        self.value = value
    }
}


extension URLRequest {
    /// The request’s HTTP headers as an array of HTTP header items.
    ///
    /// When setting this property, if multiple items have the same header field, they are added incrementally using
    /// ``add(_:)``.
    public var httpHeaderItems: [HTTPHeaderItem] {
        get {
            guard let allHTTPHeaderFields else {
                return []
            }

            return allHTTPHeaderFields.map { HTTPHeaderItem(field: .init($0), value: $1) }
        }


        set {
            // Clear all the fields. If we don’t do this in this particular way, the previous values are not cleared.
            // That is, setting allHTTPHeaderFields = [:] or nil does not have the desired effect
            if let fields = allHTTPHeaderFields?.keys {
                for field in fields {
                    setValue(nil, forHTTPHeaderField: field)
                }
            }

            for item in newValue {
                add(item)
            }
        }
    }


    /// Incrementally adds the specified HTTP header item to the request.
    ///
    /// If a value was previously set for the item’s field, the item’s value is appended to the existing value using the
    /// appropriate field delimiter (a comma).
    ///
    /// - Parameter item: The HTTP header item to add.
    public mutating func add(_ item: HTTPHeaderItem) {
        addHTTPHeaderValue(item.value, for: item.field)
    }

    
    /// Sets the specified HTTP header item on the request.
    ///
    /// - Parameter item: The HTTP header item to set.
    public mutating func set(_ item: HTTPHeaderItem) {
        setHTTPHeaderValue(item.value, for: item.field)
    }
}


extension HTTPURLResponse {
    /// The response’s HTTP headers as an array of HTTP header items.
    public var httpHeaderItems: [HTTPHeaderItem] {
        return allHeaderFields.compactMap { (field, value) in
            // This should never happen, but…
            guard let field = field as? String, let value = value as? String else {
                return nil
            }

            return HTTPHeaderItem(field: .init(field), value: value)
        }
    }
}
