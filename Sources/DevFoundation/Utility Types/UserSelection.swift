//
//  UserSelection.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 10/22/25.
//

import Foundation

/// A generic structure that manages a user’s selection with a fallback to a default value.
///
/// `UserSelection` prioritizes explicit user choices over programmatic defaults while maintaining separate tracking
/// of both values. When a user has made an explicit selection, that choice is always preserved and used, regardless
/// of changes to the default value. This ensures user preferences are never accidentally overwritten by programmatic
/// updates to defaults.
///
/// For example,
///
///     // Programmatically set an initial default theme
///     var themeSelection = UserSelection(defaultValue: "light")
///     print(themeSelection.value) // "light"
///
///     // User explicitly selects a theme
///     themeSelection.selectedValue = "dark"
///     print(themeSelection.value) // "dark"
///
///     // Programmatically update the default theme preference
///     themeSelection.defaultValue = "auto"
///     print(themeSelection.value) // Still "dark" - user’s choice is preserved
///
///     // User clears their selection to use programmatic default
///     themeSelection.selectedValue = nil
///     print(themeSelection.value) // "auto" - now uses updated programmatic default
///
/// This pattern is particularly useful when you need to distinguish between user-specified values and
/// programmatically-determined defaults that may change over time, ensuring explicit user choices are never overwritten
/// by updated defaults.
///
/// ## Protocol Conformance
///
/// `UserSelection` conditionally conforms to `Codable`, `Equatable`, `Hashable`, and `Sendable` when the wrapped
/// `Value` type also conforms to these protocols, making it suitable for persistence, comparison, hashing, and
/// concurrent programming scenarios.
public struct UserSelection<Value> {
    /// The default value to use when no selection has been made.
    ///
    /// This value is always available and serves as the fallback when `selectedValue` is `nil`.
    public var defaultValue: Value

    /// The user’s optional selection.
    ///
    /// When `nil`, the `value` property will return `defaultValue`. When set to a value, the `value` property will
    /// return this selection.
    public var selectedValue: Value?


    /// Creates a new user selection with the specified default value.
    ///
    /// - Parameter defaultValue: The value to use when no selection has been made.
    public init(defaultValue: Value) {
        self.defaultValue = defaultValue
    }


    /// The effective value, either the user’s selection or the default value.
    ///
    /// This computed property returns `selectedValue` if it’s not `nil`, otherwise it returns `defaultValue`.
    public var value: Value {
        selectedValue ?? defaultValue
    }
}


extension UserSelection: Decodable where Value: Decodable {}
extension UserSelection: Encodable where Value: Encodable {}
extension UserSelection: Equatable where Value: Equatable {}
extension UserSelection: Hashable where Value: Hashable {}
extension UserSelection: Sendable where Value: Sendable {}
