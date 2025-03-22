//
//  TypedExtensibleEnum.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/12/25.
//

import Foundation


/// A type whose instances represent an extensible set of known values.
///
/// Typed extensible enums provide an extensible way to represent strongly-typed constants. Its interface is modeled
/// similarly to how Foundation’s `Notification.Name` is implemented, and its use is similar: programmers use a strong
/// strong type instead of a string or numeric type to gain additional type safety. New “cases” of the conforming type
/// are added via extensions as static properties, and cases can be added from any Swift package that imports the
/// conforming type.
public protocol TypedExtensibleEnum: RawRepresentable, Hashable, Sendable where RawValue: Hashable & Sendable {
    /// Creates a new instance with the specified raw value.
    ///
    /// - Parameter rawValue: The raw value to use for the new instance.
    init(_ rawValue: RawValue)
}


extension TypedExtensibleEnum {
    public init(rawValue: RawValue) {
        self.init(rawValue)
    }
}
