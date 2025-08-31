//
//  Responder.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/17/25.
//

import Foundation
import Synchronization
import os

extension SimulatedURLRequestLoader {
    /// A responder that generates responses to requests that satisfy its conditions.
    ///
    /// A responder combines request conditions with a response generator to provide simulated responses for matching
    /// requests. Each responder evaluates incoming requests against its conditions and, if all conditions are met,
    /// generates a response using its configured response generator.
    ///
    /// Responders can be configured to respond a limited number of times, which is useful for testing scenarios where
    /// you want to simulate different responses over time or ensure that certain requests only succeed once.
    ///
    /// It is rare to create responders directly unless you’re creating a custom response generator. Instead, you’ll
    /// typically use one of
    ///
    ///   - ``SimulatedURLRequestLoader/respond(with:delay:maxResponses:when:)``
    ///   - ``SimulatedURLRequestLoader/respond(with:headerItems:body:delay:maxResponses:when:)``,
    ///   - ``SimulatedURLRequestLoader/respond(with:headerItems:body:encoding:delay:maxResponses:when:)``
    ///   - ``SimulatedURLRequestLoader/respond(with:headerItems:body:encoder:delay:maxResponses:when:)``.
    public final class Responder: HashableByID, Sendable {
        /// A data type used to track how many tyime a responder has responded.
        private struct ResponseCounter: Hashable {
            /// The number of times the responder has responded.
            var value: Int = 0

            /// The maximum number of times the responder should respond.
            var max: Int?


            /// Whether the responder has responded enough times to be considered fulfilled.
            ///
            /// This property is true when
            ///
            ///   - `max` is non-`nil`, and `value` is equal to `max`
            ///   - `max` is `nil`, and `value` is positive
            var isFulfilled: Bool {
                return max.map { (max) in value == max } ?? (value > 0)
            }


            /// Whether the responder should respond.
            ///
            /// If `max` is `nil`, this property is always true. Otherwise, it is only true when the responder is not
            /// fulfilled.
            var shouldRespond: Bool {
                return max != nil ? !isFulfilled : true
            }
        }


        /// The request conditions that must be fulfilled for the responder to respond.
        public let requestConditions: [any RequestCondition]

        /// The response generator that the responder uses to generate responses.
        public let responseGenerator: any ResponseGenerator


        /// The responder’s response counter, protected by a mutex.
        private let responseCounter: Mutex<ResponseCounter>


        /// Creates a new responder with the specified request conditions, response generator, and max responses.
        ///
        /// - Parameters:
        ///   - requestConditions: The request conditions that must be fulfilled for the responder to respond.
        ///   - responseGenerator: The response generator that the responder uses to generate responses.
        ///   - maxResponses: The maximum number of times the responder will respond. Defaults to 1.
        public init(
            requestConditions: [any RequestCondition],
            responseGenerator: any ResponseGenerator,
            maxResponses: Int? = 1
        ) {
            self.requestConditions = requestConditions
            self.responseGenerator = responseGenerator
            self.responseCounter = Mutex(.init(max: maxResponses))
        }


        /// Whether the responder is fulfilled.
        ///
        /// A responder is fulfilled when
        ///
        ///   - `maxResponses` is `nil`, and the responder has responded at least once
        ///   - `maxResponses` is non-`nil`, and the responder has responded `maxResponses` times
        public var isFulfilled: Bool {
            return responseCounter.withLock(\.isFulfilled)
        }


        /// The maximum number of times the responder will respond.
        ///
        /// If `nil`, the responder will never stop responding.
        public var maxResponses: Int? {
            return responseCounter.withLock(\.max)
        }


        /// Returns a response for the specified request components.
        ///
        /// Returns a non-`nil` value when the responder has not yet responded `maxResponses` times, all its requst
        /// conditions are satisfied, and its response generator is able to generate a response. Returns `nil`
        /// otherwise.
        ///
        /// - Parameter requestComponents: The request components to respond to.
        func respond(to requestComponents: RequestComponents) async throws -> (Data, URLResponse)? {
            guard
                responseCounter.withLock(\.shouldRespond),
                evaluateRequestConditions(with: requestComponents),
                let (response, delay) = await responseGenerator.response(for: requestComponents),
                await incrementResponseCounterAndSleep(for: delay)
            else {
                return nil
            }

            return try response.get()
        }


        /// Evaluates and logs request conditions using the specified request components.
        ///
        /// - Parameter requestComponents: The request components with which to evaluate request conditions.
        /// - Returns: Whether the request conditions are all fulfilled.
        private func evaluateRequestConditions(with requestComponents: RequestComponents) -> Bool {
            simulatedURLRequestLoaderLogger.debug(
                "Evaluating if \(String(describing: requestComponents.urlRequest)) satisfies request conditions"
            )

            for condition in requestConditions {
                let isFulfilled = condition.isFulfilled(by: requestComponents)
                simulatedURLRequestLoaderLogger.debug(
                    "  - \(String(describing: condition)): \(isFulfilled ? "fulfilled" : "not fulfilled")"
                )

                if !isFulfilled {
                    return false
                }
            }

            return true
        }


        /// Increments the response counter and sleeps for the specified duration.
        ///
        /// If the counter returns `false` for `shouldRespond`, does nothing and returns `false`. Otherwise, increments
        /// the response counter and sleeps if `duration` is positive.
        ///
        /// - Parameter duration: The duration for which to sleep.
        /// - Returns: Whether the response counter was incremented.
        private func incrementResponseCounterAndSleep(for duration: Duration) async -> Bool {
            let didIncrement = responseCounter.withLock { (counter) in
                guard counter.shouldRespond else {
                    return false
                }

                counter.value += 1
                return true
            }

            if didIncrement, duration > .zero {
                try? await Task.sleep(for: duration)
            }

            return didIncrement
        }
    }
}
