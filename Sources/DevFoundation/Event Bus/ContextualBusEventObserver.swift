//
//  ContextualBusEventObserver.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/28/25.
//

import Foundation
import Synchronization

/// A bus event observer that enables handling events with closures that share some common context.
public final class ContextualBusEventObserver<Context>: BusEventObserver where Context: Sendable {
    /// A struct representing the type’s internal mutable state.
    ///
    /// An instance of this type is protected using a mutex.
    private struct State: Sendable {
        /// The instance’s event handlers.
        ///
        /// These handlers were not registered with a specific ID.
        var eventHandlers: [EventHandlerKey: [any EventHandler]] = [:]

        /// The instance’s identifiable event handlers.
        ///
        /// These handlers were registered with a specific ID.
        var identifiableEventHandlers: [IdentifiableEventHandlerKey: [any EventHandler]] = [:]
    }


    /// The dispatcher which calls registered handlers on behalf of the observer.
    ///
    /// This instance stores the observer’s context and passes it to handlers.
    private let dispatcher: Dispatcher

    /// The instance’s internal mutable state, protected by a mutex.
    private let state: Mutex<State> = Mutex(.init())


    /// Creates a new contextual bus event observer with the specified context.
    ///
    /// - Parameter context: The context that stores state and behavior common to the observer’s handlers.
    public init(context: Context) {
        self.dispatcher = Dispatcher(context: context)
    }


    /// Adds a new handler for the specified event type.
    ///
    /// - Parameters:
    ///   - eventType: The type of event to handle.
    ///   - body: A closure to handle the event.
    /// - Returns: An opaque object that can be used to later remove the handler.
    @discardableResult
    public func addHandler<Event>(
        for eventType: Event.Type,
        body: @escaping @Sendable (Event, inout Context) -> Void
    ) -> AnyObject where Event: BusEvent {
        let key = EventHandlerKey(eventType: eventType)
        let handler = Handler<Event>(body: body, eventID: nil)

        state.withLock { (state) in
            state.eventHandlers[key, default: []].append(handler)
        }

        return handler
    }


    /// Adds a new handler for the specified event type and event ID.
    ///
    /// - Parameters:
    ///   - eventType: The type of event to handle.
    ///   - id: The ID of the event to handle.
    ///   - body: A closure to handle the event.
    /// - Returns: An opaque object that can be used to later remove the handler.
    @discardableResult
    public func addHandler<Event>(
        for eventType: Event.Type,
        id: Event.ID,
        body: @escaping @Sendable (Event, inout Context) -> Void
    ) -> AnyObject where Event: BusEvent & Identifiable, Event.ID: Sendable {
        let key = IdentifiableEventHandlerKey(eventType: eventType, eventID: id)
        let handler = Handler<Event>(body: body, eventID: AnySendableHashable(id))

        state.withLock { (state) in
            state.identifiableEventHandlers[key, default: []].append(handler)
        }

        return handler
    }


    /// Removes the specified handler.
    ///
    /// Does nothing if the handler was not previously added.
    ///
    /// - Parameter handler: The objected returned by ``addHandler(for:body:)`` or ``addHandler(for:id:body:)`` when the
    ///   handler was added.
    public func removeHandler(_ handler: AnyObject) {
        guard let handler = handler as? any EventHandler else {
            return
        }

        state.withLock { state in
            state.eventHandlers[EventHandlerKey(handler: handler)]?.removeFirst { $0 === handler }

            if let identiablekey = IdentifiableEventHandlerKey(handler: handler) {
                state.identifiableEventHandlers[identiablekey]?.removeFirst { $0 === handler }
            }
        }
    }


    public func observe<Event>(_ event: Event) where Event: BusEvent {
        let key = EventHandlerKey(eventType: Event.self)
        let handlers = state.withLock { $0.eventHandlers[key] as? [Handler<Event>] ?? [] }

        guard !handlers.isEmpty else {
            return
        }

        dispatcher.dispatch(event, to: handlers)
    }


    public func observe<Event>(_ event: Event) where Event: BusEvent & Identifiable, Event.ID: Sendable {
        let key = EventHandlerKey(eventType: Event.self)
        let identifiableKey = IdentifiableEventHandlerKey(event: event)

        let handlers = state.withLock { (state) in
            let handlers = state.eventHandlers[key] as? [Handler<Event>] ?? []
            let identifiableHandlers = state.identifiableEventHandlers[identifiableKey] as? [Handler<Event>] ?? []
            return handlers + identifiableHandlers
        }

        guard !handlers.isEmpty else {
            return
        }

        dispatcher.dispatch(event, to: handlers)
    }
}


// MARK: - Supporting Types

/// A type that can be used as an event handler.
///
/// This type is used to store handlers without any generic type information.
private protocol EventHandler: AnyObject, Sendable {
    /// An ID for the handler’s event type.
    var eventTypeID: ObjectIdentifier { get }

    /// The ID for the event that the handler was added with.
    ///
    /// If the handler was added using ``ContextualBusEventObserver/addObserver(for:body:)``, this value is `nil`.
    var eventID: AnySendableHashable? { get }
}


extension ContextualBusEventObserver {
    /// A key for a handler registered without an ID.
    ///
    /// Instances of this type are used as keys for `ContextualBusEventObserver.State.eventHandlers`.
    private struct EventHandlerKey: Hashable {
        /// An ID for the handler’s event type.
        let eventTypeID: ObjectIdentifier


        /// Creates a new event handler key for the specified event type.
        ///
        /// - Parameter eventType: The type of event that the handler is for.
        init<Event>(eventType: Event.Type) where Event: BusEvent {
            self.eventTypeID = ObjectIdentifier(eventType)
        }


        /// Creates a new event handler key using properties from the specified handler.
        ///
        /// - Parameter handler: The event handler from which the key’s properties will be taken.
        init(handler: some EventHandler) {
            self.eventTypeID = handler.eventTypeID
        }
    }


    /// A key for a handler registered with an ID.
    ///
    /// Instances of this type are used as keys for `ContextualBusEventObserver.State.identifiableEventHandlers`.
    private struct IdentifiableEventHandlerKey: Hashable, Sendable {
        /// An ID for the handler’s event type.
        let eventTypeID: ObjectIdentifier

        /// The event ID that the handler is for.
        let eventID: AnySendableHashable


        /// Creates a new identifiable event handler key for the specified event type and ID.
        ///
        /// - Parameters:
        ///   - eventType: The type of event that the handler is for.
        ///   - id: The event ID that the handler is for.
        init<Event>(eventType: Event.Type, eventID: Event.ID) where Event: BusEvent & Identifiable, Event.ID: Sendable {
            self.eventTypeID = ObjectIdentifier(Event.self)
            self.eventID = AnySendableHashable(eventID)
        }


        /// Creates a new identifiable event handler using properties from the specified event.
        ///
        /// - Parameter event: The event from which the key’s properties will be taken.
        init<Event>(event: Event) where Event: BusEvent & Identifiable, Event.ID: Sendable {
            self.eventTypeID = ObjectIdentifier(Event.self)
            self.eventID = AnySendableHashable(event.id)
        }


        /// Creates a new identifiable event handler key using properties from the specified event handler.
        ///
        /// Returns `nil` if the handler has no event ID.
        ///
        /// - Parameter handler: An event handler from which to get the instance’s properties.
        init?(handler: some EventHandler) {
            guard let eventID = handler.eventID else {
                return nil
            }

            self.eventTypeID = handler.eventTypeID
            self.eventID = eventID
        }
    }


    /// A wrapper for a registered handler.
    ///
    /// Instances of this type are used as values in `ContextualBusEventObserver.State`’s dictionaries.
    private final class Handler<Event>: EventHandler, Sendable where Event: BusEvent {
        /// The body of the handler.
        let body: @Sendable (Event, inout Context) -> Void

        /// The event ID with which the handler was added.
        let eventID: AnySendableHashable?


        /// Creates a new handler with the specified body and event ID.
        ///
        /// - Parameters:
        ///   - body: The handler’s body.
        ///   - The event ID with which the handler was added.
        init(
            body: @escaping @Sendable (Event, inout Context) -> Void,
            eventID: AnySendableHashable?
        ) {
            self.body = body
            self.eventID = eventID
        }


        /// Calls the handler with the specified event and context.
        ///
        /// - Parameters:
        ///   - event: An event that was observed.
        ///   - context: Shared context that the handler can use to handle the event.
        func handle(_ event: Event, with context: inout Context) {
            body(event, &context)
        }


        var eventTypeID: ObjectIdentifier {
            return ObjectIdentifier(Event.self)
        }
    }


    /// A class that stores context and dispatches events to handlers.
    private final class Dispatcher: Sendable {
        /// The shared context that can be mutated by handlers.
        nonisolated(unsafe)
            private var context: Context

        /// The dispatch queue that handlers are executed on.
        private let queue = DispatchQueue(
            label: reverseDNSPrefixed("contextual-bus-event-observer"),
            target: .utility
        )


        /// Creates a new dispatcher with the specified context.
        ///
        /// - Parameter context: Shared context that can be mutated by handlers.
        init(context: Context) {
            self.context = context
        }


        /// Sends an event to an array of handlers, passing them the instance’s shared context.
        ///
        /// - Parameters:
        ///   - event: The event to handle.
        ///   - handlers: The handlers that are registered to handle the event.
        func dispatch<Event>(_ event: Event, to handlers: [Handler<Event>]) {
            queue.async { [self] in
                for handler in handlers {
                    handler.handle(event, with: &context)
                }
            }
        }
    }
}
