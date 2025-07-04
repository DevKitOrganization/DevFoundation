//
//  EventBus.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/28/25.
//

import Foundation
import Synchronization

/// An object that sends type-safe events to registered observers.
public final class EventBus: HashableByID, Sendable {
    /// The bus’s observers.
    private let observers: Mutex<[any BusEventObserver]> = .init([])


    /// Creates a new event bus with no registered observers.
    public init() {
        // Intentionally empty
    }


    /// Adds an observer to the event bus.
    ///
    /// - Parameter observer: The observer to add.
    public func addObserver(_ observer: some BusEventObserver) {
        observers.withLock { $0.append(observer) }
    }


    /// Removes an observer from the event bus.
    ///
    /// Does nothing if the observer is not observing events from the event bus.
    ///
    /// - Parameter observer: The observer to remove.
    public func removeObserver(_ observer: some BusEventObserver) {
        observers.withLock { (observers) in
            observers.removeAll { $0 === observer }
        }
    }


    /// Posts an event to the event bus.
    ///
    /// Bus event observers are sent the event via ``BusEventObserver/observe(_:)-7p3d5``. Observers are called in the
    /// order in which they registered.
    ///
    /// - Parameter event: The bus event to post.
    public func post(_ event: some BusEvent) {
        let observers = observers.withLock { $0 }
        for observer in observers {
            observer.observe(event)
        }
    }


    /// Posts an identifiable event to the event bus.
    ///
    /// Bus event observers are sent the event via ``BusEventObserver/observe(_:)-ou69``. Observers are called in the
    /// order in which they registered.
    ///
    /// - Parameter event: The identifiable bus event to post.
    public func post<Event>(_ event: Event) where Event: BusEvent & Identifiable, Event.ID: Sendable {
        let observers = observers.withLock { $0 }
        for observer in observers {
            observer.observe(event)
        }
    }
}
