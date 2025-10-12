//
//  AnySendableHashable.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/30/25.
//

import Foundation

/// A type-erased sendable, hashable value.
public struct AnySendableHashable: Hashable, Sendable {
    /// The ``AnyHashable`` that this instance wraps.
    nonisolated(unsafe) let _base: AnyHashable


    /// Creates a type-erased sendable, hashable value that wraps the given instance.
    ///
    /// - Parameter base: A sendable, hashable value to wrap.
    public init<Base>(_ base: Base) where Base: Hashable & Sendable {
        self._base = AnyHashable(base)
    }


    /// The value wrapped by this instance.
    ///
    /// The base property can be cast back to its original type using one of the type casting operators (`as?`, `as!`,
    /// or `as`).
    ///
    ///     let anyMessage = AnySendableHashable("Hello world!")
    ///     if let unwrappedMessage = anyMessage.base as? String {
    ///         print(unwrappedMessage)
    ///     }
    ///     // Prints "Hello world!"
    public var base: Any {
        return _base.base
    }
}
