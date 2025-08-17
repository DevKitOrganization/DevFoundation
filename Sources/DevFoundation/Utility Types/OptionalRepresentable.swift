//
//  OptionalRepresentable.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/16/25.
//

import Foundation

/// A type whose instances have an `Optional` representation.
///
/// `OptionalRepresentable` addresses a Swift language limitation related to protocol extensions and associated types
/// that are optionals. Specifically, given a protocol `P` with some associated type `T`, you cannot write a protocol
/// extension on `P` that requires `T` to be optional. `OptionalRepresentable` and `Optional`’s conformance to it allow
/// you to do so. For example, the following extension effectively requires that `T` be an `Optional`.
///
///     extension P where T: OptionalRepresentable {
///         …
///     }
///
/// We can constrain the extension to the optional’s wrapped type as follows:
///
///     extension P where T: OptionalRepresentable, T.Wrapped: Hashable {
///         …
///     }
///
/// DevFoundation adds `OptionalRepresentable` conformance to `Optional`, which is likely the only type that should
/// conform.
public protocol OptionalRepresentable<Wrapped> {
    associatedtype Wrapped

    /// An optional representation of the instance.
    var optionalRepresentation: Wrapped? { get }
}


extension Optional: OptionalRepresentable {
    /// Returns `self`.
    public var optionalRepresentation: Wrapped? {
        self
    }
}
