//
//  DottedHierarchicalID.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/13/25.
//

import Foundation


/// A type representing a string identifier that uses period characters to indicate hierarchy.
///
/// `DottedHierarchicalIDs`s provide a type-safe way to store IDs in what is commonly referred to as reverse-DNS
/// notation, e.g., `"com.spacely.sprockets"` or `"com.spacely.widgets"`. The protocol includes functions like
/// ``isAncestor(of:)`` and ``isDescendent(of:)`` to programmatically inspect hierachy, as well as `appending(_:)`,
/// which makes it easy to create a child ID by appending an additional component to its parent.
///
/// ## Creating a Conforming Type
///
/// Conforming types often conform to ``TypedExtensibleEnum``, but this is not required. We provide a static function,
/// ``rawValueOmittingEmptyComponents(_:)``, which you will almost always use in your initializer to remove any empty
/// components from the `rawValue` parameter before storing it. If you wish to perform any other input sanitization or
/// canonicalization, you should do so in your initializer. For example, the following initializer omits empty
/// components and then lowercases the string before storing it.
///
///     init(_ rawValue: String) {
///         self.rawValue = Self.rawValueOmittingEmptyComponents(rawValue).lowercased()
///     }
public protocol DottedHierarchicalID: RawRepresentable where RawValue == String {
    /// Whether the ID is an ancestor of another.
    ///
    /// Calling this function on an ID whose raw value is the empty string always returns `false`.
    ///
    /// The default implementation checks if `other`’s components start with with the instance’s, where component
    /// equivalence is defined as string equality. If you wish to use some other definition of equivalence, e.g., case-
    /// or diacritic-insensitive string comparison, you should provide your own implementation.
    ///
    /// - Parameter other: The other ID.
    func isAncestor(of other: Self) -> Bool
}


extension DottedHierarchicalID {
    /// Returns a copy of the raw value with multiple consecutive period characters replaced by a single period.
    ///
    /// For example, when calling this function with, `"com..spacely...sprockets"`, `"com.spacely.sprockets"` is
    /// returned.
    ///
    /// - Parameter rawValue: The raw value from which to omit empty components.
    public static func rawValueOmittingEmptyComponents(_ rawValue: String) -> String {
        return rawValue.split(separator: ".", omittingEmptySubsequences: true).joined(separator: ".")
    }


    public func isAncestor(of other: Self) -> Bool {
        guard !rawValue.isEmpty else {
            return false
        }

        return other.components.starts(with: components)
    }


    /// Whether the ID is a descendent of another.
    ///
    /// - Parameter other: The other ID.
    public func isDescendent(of other: Self) -> Bool {
        return other.isAncestor(of: self)
    }


    /// Finds the lowest common ancestor between the ID and another.
    ///
    /// For two IDs with raw values of `com.spacely.sprockets` and `com.spacely.widgets`, their lowest common ancestor
    /// is `com.spacely`.
    ///
    /// - Parameter other: The other ID.
    /// - Returns: The lowest common ancestor between ID and `other`. If there is no common ancestor, returns `nil`.
    public func lowestCommonAncestor(with other: Self) -> Self? {
        var ancestor: Self? = nil
        for component in components.map(String.init(_:)) {
            guard let candidate = ancestor.flatMap({ $0.appending(component) }) ?? Self(rawValue: component),
                  candidate.isAncestor(of: other)
            else {
                return ancestor
            }

            ancestor = candidate
        }

        return ancestor
    }


    /// Creates a new ID by appending a period followed by the specified suffix.
    ///
    /// - Parameter suffix: The suffix to append.
    public func appending(_ suffix: Self) -> Self? {
        return Self(rawValue: "\(rawValue).\(suffix.rawValue)")
    }


    /// Creates a new instance by appending a period followed by the specified string suffix.
    ///
    /// - Parameter stringSuffix: The string suffix to append.
    public func appending(_ stringSuffix: String) -> Self? {
        return Self(rawValue: stringSuffix).flatMap(appending(_:))
    }


    /// The instance’s components.
    private var components: [Substring] {
        return rawValue.split(separator: ".")
    }
}


extension TypedExtensibleEnum where Self: DottedHierarchicalID {
    /// Creates a new ID by appending a period followed by the specified suffix.
    ///
    /// - Parameter suffix: The suffix to append.
    public func appending(_ suffix: Self) -> Self {
        return Self("\(rawValue).\(suffix.rawValue)")
    }


    /// Creates a new ID by appending a period followed by the specified string suffix.
    ///
    /// - Parameter stringSuffix: The suffix to append.
    public func appending(_ stringSuffix: String) -> Self {
        return appending(Self(stringSuffix))
    }
}
