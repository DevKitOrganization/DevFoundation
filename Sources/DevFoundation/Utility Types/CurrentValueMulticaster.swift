//
//  CurrentValueMulticaster.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 6/30/26.
//

import Foundation
import Synchronization

/// A reference that holds a current value and multicasts it, plus every subsequent update, to many independent async
/// sequence consumers.
///
/// `CurrentValueMulticaster` is the async sequence analogue of Combine’s `CurrentValueSubject`. It holds a current
/// value that callers can read and write through ``value``, and it vends async sequences via ``values()``. Each vended
/// sequence immediately emits the current value, then every subsequent update.
///
/// Unlike ``ObservableReference``, which is best consumed using the Observation framework and SwiftUI, this type is
/// designed for publishing a current value from an `actor` or to `AsyncSequence` consumers. A subscriber’s sequence is
/// registered, and the current value emitted to it, under the same lock that updates take, so no update can slip into
/// the gap between reading the current value and subscribing. Publishing is synchronous and never suspends, so an
/// owning actor never waits on a slow consumer, and each consumer has its own buffer, so consumers never delay one
/// another.
public final class CurrentValueMulticaster<Element>: Sendable where Element: Sendable {
    /// A policy that determines how a consumer’s sequence buffers values that it has not yet received.
    ///
    /// Each consumer buffers independently. The default, ``bufferingNewest(_:)`` with a count of `1`, yields
    /// current-value semantics: if updates arrive before a consumer pulls, only the most recent is retained.
    public enum BufferingPolicy: Sendable, Hashable {
        /// Buffers an unbounded number of values.
        case unbounded

        /// Buffers the specified number of newest values, dropping older values to make room.
        case bufferingNewest(Int)

        /// Buffers the specified number of oldest values, dropping newer values once full.
        case bufferingOldest(Int)
    }


    /// The mutable state that the multicaster guards behind a single lock.
    private struct State {
        /// The current value.
        var currentValue: Element

        /// The continuations of the multicaster’s active consumer sequences, keyed by a per-consumer identifier.
        var continuations: [UUID: AsyncStream<Element>.Continuation]
    }


    /// The buffering policy applied to each consumer’s sequence.
    private let bufferingPolicy: BufferingPolicy

    /// A mutex that synchronizes access to the multicaster’s state.
    private let state: Mutex<State>


    /// Creates a new multicaster with the specified initial value.
    ///
    /// - Parameters:
    ///   - initialValue: The initial value that the multicaster holds and emits to new consumers.
    ///   - bufferingPolicy: The policy applied to each consumer’s sequence. The default, `.bufferingNewest(1)`,
    ///     yields current-value semantics.
    public init(
        _ initialValue: Element,
        bufferingPolicy: BufferingPolicy = .bufferingNewest(1),
    ) {
        self.bufferingPolicy = bufferingPolicy
        self.state = .init(State(currentValue: initialValue, continuations: [:]))
    }


    deinit {
        state.withLock { (state) in
            for (_, continuation) in state.continuations {
                continuation.finish()
            }
        }
    }


    /// The multicaster’s current value.
    ///
    /// Reading returns the current value. Assigning updates it and synchronously emits the new value to every active
    /// consumer. Assignment emits on every write, even when the new value equals the old one.
    public var value: Element {
        get {
            state.withLock(\.currentValue)
        }

        set {
            state.withLock { (state) in
                state.currentValue = newValue
                for continuation in state.continuations.values {
                    continuation.yield(newValue)
                }
            }
        }
    }


    /// Returns a sequence that emits the current value immediately, then every subsequent update.
    ///
    /// Each call returns an independent sequence with its own buffer, governed by the multicaster’s buffering policy.
    /// The sequence finishes when the consumer’s task is cancelled or when the multicaster is deallocated.
    public func values() -> some AsyncSequence<Element, Never> & Sendable {
        let id = UUID()

        // `makeStream` is used rather than the closure-based `AsyncStream` initializer on purpose: that initializer’s
        // build closure would capture `self` strongly and be retained for the stream’s lifetime, so a consumer
        // holding the stream would keep the multicaster alive — preventing deallocation and the stream from ever
        // finishing. Here the only retained closure is `onTermination`, which holds `self` weakly.
        let (stream, continuation) = AsyncStream<Element>.makeStream(
            bufferingPolicy: bufferingPolicy.asyncStreamBufferingPolicy
        )

        continuation.onTermination = { [weak self] _ in
            self?.state.withLock { $0.continuations[id] = nil }
        }

        // Yield the current value and register the continuation under the same lock that updates take, so no update
        // can slip into the gap between reading the current value and subscribing.
        state.withLock { (state) in
            continuation.yield(state.currentValue)
            state.continuations[id] = continuation
        }

        return stream
    }
}


extension CurrentValueMulticaster.BufferingPolicy {
    /// The equivalent `AsyncStream` buffering policy.
    fileprivate var asyncStreamBufferingPolicy: AsyncStream<Element>.Continuation.BufferingPolicy {
        switch self {
        case .unbounded:
            .unbounded
        case .bufferingNewest(let count):
            .bufferingNewest(count)
        case .bufferingOldest(let count):
            .bufferingOldest(count)
        }
    }
}
