//
//  SimulatedURLRequestLoader.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/17/25.
//

import Foundation
import Synchronization
import os.log

/// DevFoundation’s logger for outputting information about the simulated URL request loader.
let simulatedURLRequestLoaderLogger = Logger(subsystem: "DevFoundation", category: "simulatedURLRequestLoader")


/// A URL request loader that can simulate loading a request using client-side responders.
public final class SimulatedURLRequestLoader: URLRequestLoader {
    /// A mutex that protects access to the instance’s array of responders.
    private let respondersMutex: Mutex<[Responder]> = .init([])


    /// Creates a new simulated URL request loader.
    public init() {
        // Intentionally empty
    }


    /// The instance’s registered responders.
    public var responders: [Responder] {
        return respondersMutex.withLock(\.self)
    }


    /// The instance’s responders that have not yet been fulfilled.
    public var unfulfilledResponders: [Responder] {
        return responders.filter { !$0.isFulfilled }
    }


    /// Adds the specified responder to the instance.
    ///
    /// - Parameter responder: The responder to add.
    public func add(_ responder: Responder) {
        respondersMutex.withLock { $0.append(responder) }
    }


    public func data(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        if let requestComponents = RequestComponents(urlRequest: urlRequest) {
            for responder in responders {
                if let (data, response) = try await responder.respond(to: requestComponents) {
                    return (data, response)
                }
            }
        }

        throw UnfulfillableRequestError(request: urlRequest)
    }
}
