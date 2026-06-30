//
//  ObservableReference.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 9/24/25.
//

import Foundation
import Synchronization

/// A reference whose value changes can be observed.
///
/// `ObservableReference` is best consumed using the Observation framework and SwiftUI. To publish a current value
/// from an `actor`, or to consume value changes as an `AsyncSequence`, prefer ``CurrentValueMulticaster``, which
/// avoids the timing pitfalls of bridging Observation into an async sequence.
@Observable
public final class ObservableReference<Value>: Sendable where Value: Sendable {
    /// A mutex that synchronizes access to the reference’s value.
    private let valueMutex: Mutex<Value>


    /// Creates a new observable reference with the specified initial value.
    ///
    /// - Parameter initialValue: The initial value that the reference contains.
    public init(_ initialValue: Value) {
        self.valueMutex = .init(initialValue)
    }


    /// The reference’s value.
    public var value: Value {
        get {
            access(keyPath: \.value)
            return valueMutex.withLock { $0 }
        }

        set {
            withMutation(keyPath: \.value) {
                valueMutex.withLock { (value) in
                    value = newValue
                }
            }
        }
    }
}
