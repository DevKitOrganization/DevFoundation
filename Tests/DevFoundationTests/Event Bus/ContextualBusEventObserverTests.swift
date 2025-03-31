//
//  ContextualBusEventObserverTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 4/4/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing


struct ContextualBusEventObserverTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()

    private let eventBus: EventBus
    private let observer: ContextualBusEventObserver<Int>


    init() {
        self.eventBus = EventBus()
        self.observer = ContextualBusEventObserver(context: 0)

        eventBus.addObserver(observer)
    }


    @Test
    mutating func postingUnhandledEventDoesNothing() async throws {
        try await confirmation("handler is not called", expectedCount: 0) { (didCallHandler) in
            observer.addHandler(
                for: MockIdentifiableBusEvent.self,
                id: random(Int.self, in: .min ... .max)
            ) { (_, _) in
                didCallHandler()
            }

            eventBus.post(MockBusEvent(string: randomAlphanumericString()))
            try await Task.sleep(for: .seconds(0.5))
        }
    }


    @Test
    mutating func postingUnhandledIdentifiableEventDoesNothing() async throws {
        try await confirmation("handler is not called", expectedCount: 0) { (didCallHandler) in
            observer.addHandler(for: MockBusEvent.self) { (_, _) in didCallHandler() }
            observer.addHandler(
                for: MockIdentifiableBusEvent.self,
                id: random(Int.self, in: .min  ..< 0)
            ) { (_, _) in
                didCallHandler()
            }

            eventBus.post(
                MockIdentifiableBusEvent(
                    id: random(Int.self, in: 0 ... .max),
                    string: randomAlphanumericString()
                )
            )
            try await Task.sleep(for: .seconds(0.5))
        }
    }


    @Test
    mutating func postingHandledEventCallsAllHandlers() async throws {
        let expectedString = randomAlphanumericString()
        let handlerCount = random(Int.self, in: 3 ... 5)

        try await confirmation("handlers are called", expectedCount: handlerCount) { (didCallHandler) in
            for i in 0 ..< handlerCount {
                observer.addHandler(for: MockBusEvent.self) { (event, context) in
                    #expect(event.string == expectedString)
                    #expect(context == i)
                    context += 1
                    didCallHandler()
                }
            }

            eventBus.post(MockBusEvent(string: expectedString))
            try await Task.sleep(for: .seconds(0.5))
        }
    }


    @Test
    mutating func postingHandledIdentifiableEventCallsAllHandlers() async throws {
        let expectedID = random(Int.self, in: 0 ... 100)
        let expectedString = randomAlphanumericString()
        let handlerCount = random(Int.self, in: 3 ... 5)

        try await confirmation("handlers are called", expectedCount: handlerCount * 2) { (didCallHandler) in
            for i in 0 ..< handlerCount {
                observer.addHandler(for: MockIdentifiableBusEvent.self) { (event, context) in
                    #expect(event.id == expectedID)
                    #expect(event.string == expectedString)

                    // Expect all the non-Identifiable event handlers to be called before the Identifiable ones
                    #expect(context == i)
                    context += 1
                    didCallHandler()
                }

                observer.addHandler(for: MockIdentifiableBusEvent.self, id: expectedID) { (event, context) in
                    #expect(event.id == expectedID)
                    #expect(event.string == expectedString)

                    // Expect all the Identifiable event handlers to be called after the non-Identifiable ones
                    #expect(context == handlerCount + i)
                    context += 1
                    didCallHandler()
                }
            }

            eventBus.post(MockIdentifiableBusEvent(id: expectedID, string: expectedString))
            try await Task.sleep(for: .seconds(0.5))
        }
    }


    @Test
    mutating func removeHandlerWorksWhenHandlerIsForNonIdentifiableEvent() async throws {
        try await confirmation("removed handler is not called", expectedCount: 0) { (didCallHandler) in
            let handler = observer.addHandler(for: MockBusEvent.self) { (event, context) in
                didCallHandler()
            }
            observer.removeHandler(handler)
            eventBus.post(MockBusEvent(string: randomAlphanumericString()))
            try await Task.sleep(for: .seconds(0.5))
        }
    }


    @Test
    mutating func removeHandlerWorksWhenHandlerIsForIdentifiableEvent() async throws {
        try await confirmation("removed handler is not called", expectedCount: 0) { (didCallHandler) in
            let handler = observer.addHandler(
                for: MockIdentifiableBusEvent.self,
                id: random(Int.self, in: .min ... .max)
            ) { (event, context) in
                didCallHandler()
            }
            observer.removeHandler(handler)
            eventBus.post(
                MockIdentifiableBusEvent(
                    id: random(Int.self, in: .min ... .max),
                    string: randomAlphanumericString()
                )
            )
            try await Task.sleep(for: .seconds(0.5))
        }
    }


    @Test
    mutating func removeHandlerDoesNothingHandlerIsNotHandler() {
        observer.removeHandler(NSObject())
    }
}
