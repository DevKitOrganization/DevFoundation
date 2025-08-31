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


/// A URL request loader that simulates network requests for development and testing.
///
/// `SimulatedURLRequestLoader` provides a way to intercept and respond to network requests without making actual
/// network calls. This is particularly useful for unit tests, development environments where backend services are
/// unavailable, or when you need predictable responses for integration testing.
///
/// The loader operates by matching incoming requests against a collection of configured responders. Each responder
/// defines conditions that a request must meet, and generates appropriate responses when those conditions are
/// satisfied. Responders are evaluated in the order they were added.
///
/// ## Basic Usage
///
/// Create a loader and add responders with specific conditions:
///
///     let loader = SimulatedURLRequestLoader()
///     loader.respond(
///         with: .created,
///         body: UserCreatedResponse(id: 456),
///         when: [
///             .httpMethod(equals: .post),
///             .hostEquals("api.example.com"),
///             .pathEquals("/users"),
///         ]
///     )
///
/// There are a wide variety of request conditions that can be specified. Additionally, responders can be configured
/// to
///
///   - Respond with an error
///   - Delay responses to simulate network latency
///   - Respond a maximum number of times, which is useful when writing automated tests
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
