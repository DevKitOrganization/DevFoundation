//
//  BusEventObserver.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/30/25.
//

import Foundation

/// A type that can observe events posted to an event bus.
///
/// In general, you will rarely need to conform to this type; ``ContextualBusEventObserver`` provides an implementation
/// that should cover most needs.
public protocol BusEventObserver: AnyObject, Sendable {
    /// Observe a bus event that was posted to an event bus.
    ///
    /// - Parameter event: The bus event to observe.
    func observe(_ event: some BusEvent)

    /// Observe an identifiable bus event that was posted to an event bus.
    ///
    /// - Parameter event: The identifiable bus event to observe.
    func observe<Event>(_ event: Event) where Event: BusEvent & Identifiable, Event.ID: Sendable
}
