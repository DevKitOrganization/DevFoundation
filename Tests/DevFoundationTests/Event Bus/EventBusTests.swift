//
//  EventBusTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 4/1/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing


struct EventBusTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func testAllFunctionality() {
        // Create an event bus
        let eventBus = EventBus()

        // Add some observers
        let observers = Array(count: random(Int.self, in: 3 ... 5)) {
            let observer = MockBusEventObserver()
            observer.observeStub = .init()
            observer.observeIdentifiableStub = .init()
            return observer
        }

        for observer in observers {
            eventBus.addObserver(observer)
        }

        // Post some (non-Identifiable) events
        let busEvents = Array(count: random(Int.self, in: 3 ... 5)) {
            MockBusEvent(string: randomAlphanumericString())
        }

        for busEvent in busEvents {
            eventBus.post(busEvent)
        }

        for observer in observers {
            #expect(observer.observeStub.callArguments as? [MockBusEvent] == busEvents)
            #expect(observer.observeIdentifiableStub.calls.isEmpty)
        }

        // Post some identifiable bus events
        let identifiableBusEvents = Array(count: random(Int.self, in: 3 ... 5)) {
            MockIdentifiableBusEvent(
                id: random(Int.self, in: 0 ... .max),
                string: randomAlphanumericString()
            )
        }

        for identifiableBusEvent in identifiableBusEvents {
            eventBus.post(identifiableBusEvent)
        }

        for observer in observers {
            #expect(observer.observeStub.callArguments as? [MockBusEvent] == busEvents)
            #expect(
                observer.observeIdentifiableStub.callArguments as? [MockIdentifiableBusEvent] == identifiableBusEvents
            )
        }

        // Remove all observers
        for observer in observers {
            eventBus.removeObserver(observer)
            observer.observeStub.clearCalls()
            observer.observeIdentifiableStub.clearCalls()
        }

        // Post an event and make sure the old observers don}t receive it
        eventBus.post(MockBusEvent(string: randomAlphanumericString()))
        for observer in observers {
            #expect(observer.observeStub.calls.isEmpty)
            #expect(observer.observeIdentifiableStub.calls.isEmpty)
        }
    }


    @Test
    mutating func testFunctionalityWithDuplicateObservers() throws {
        // Create an event bus
        let eventBus = EventBus()

        // Add a new observer multiple times
        let observer = MockBusEventObserver()
        observer.observeStub = .init()
        observer.observeIdentifiableStub = .init()

        let duplicateObservationCount = random(Int.self, in: 3 ... 5)
        for _ in 0 ..< duplicateObservationCount {
            eventBus.addObserver(observer)
        }

        // Post an event and make sure the same event is received multiple times
        let event = MockBusEvent(string: randomAlphanumericString())
        eventBus.post(event)
        let nonIdentifiableArguments = try #require(observer.observeStub.callArguments as? [MockBusEvent])
        #expect(nonIdentifiableArguments == Array(repeating: event, count: duplicateObservationCount))

        // Post an event and make sure the same event is received multiple times
        let identifiableEvent = MockIdentifiableBusEvent(
            id: random(Int.self, in: .min ... .max),
            string: randomAlphanumericString()
        )
        eventBus.post(identifiableEvent)
        let identifiableArguments = try #require(
            observer.observeIdentifiableStub.callArguments as? [MockIdentifiableBusEvent]
        )
        #expect(identifiableArguments == Array(repeating: identifiableEvent, count: duplicateObservationCount))

        // Clear stubs
        observer.observeStub.clearCalls()
        observer.observeIdentifiableStub.clearCalls()

        // Remove the observer and post the events again
        eventBus.removeObserver(observer)
        eventBus.post(event)
        eventBus.post(identifiableEvent)
        #expect(observer.observeStub.calls.isEmpty)
        #expect(observer.observeIdentifiableStub.calls.isEmpty)
    }
}
