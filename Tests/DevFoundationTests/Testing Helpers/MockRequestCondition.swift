//
//  MockRequestCondition.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/31/25.
//

import DevFoundation
import DevTesting
import Foundation

final class MockRequestCondition: SimulatedURLRequestLoader.RequestCondition, HashableByID {
    nonisolated(unsafe) var isFulfilledStub: Stub<SimulatedURLRequestLoader.RequestComponents, Bool>!
    nonisolated(unsafe) var descriptionStub: Stub<Void, String>!


    func isFulfilled(by requestComponents: SimulatedURLRequestLoader.RequestComponents) -> Bool {
        return isFulfilledStub(requestComponents)
    }


    var description: String {
        return descriptionStub()
    }
}
