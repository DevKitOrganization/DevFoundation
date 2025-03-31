//
//  MockBusEventObserver.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 4/1/25.
//

import DevFoundation
import DevTesting
import Foundation


final class MockBusEventObserver: BusEventObserver {
    nonisolated(unsafe)
    var observeStub: Stub<any BusEvent, Void>!


    nonisolated(unsafe)
    var observeIdentifiableStub: Stub<any BusEvent & Identifiable, Void>!


    func observe(_ event: some BusEvent) {
        observeStub(event)
    }
    

    func observe<Event>(_ event: Event) where Event: BusEvent & Identifiable, Event.ID: Sendable {
        observeIdentifiableStub(event)
    }
}
