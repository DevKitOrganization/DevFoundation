//
//  Responder.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/17/25.
//

import Foundation
import Synchronization

extension SimulatedURLRequestLoader {
    public final class Responder: HashableByID, Sendable {
        private struct ResponseCounter: Hashable {
            var value: Int = 0
            var max: Int?


            var isFulfilled: Bool {
                return max.map { (max) in value == max } ?? (value > 0)
            }


            var shouldRespond: Bool {
                return max != nil ? !isFulfilled : true
            }
        }


        public let requestConditions: [any RequestCondition]
        public let responseGenerator: any ResponseGenerator
        private let responseCounter: Mutex<ResponseCounter>


        public init(
            requestConditions: [any RequestCondition],
            responseGenerator: any ResponseGenerator,
            maxResponses: Int? = 1
        ) {
            self.requestConditions = requestConditions
            self.responseGenerator = responseGenerator
            self.responseCounter = Mutex(.init(max: maxResponses))
        }


        public var isFulfilled: Bool {
            return responseCounter.withLock(\.isFulfilled)
        }


        public var maxResponses: Int? {
            return responseCounter.withLock(\.max)
        }


        public func respond(to requestComponents: RequestComponents) async throws -> (Data, URLResponse)? {
            guard
                responseCounter.withLock(\.shouldRespond),
                requestConditions.allSatisfy({ $0.isFulfilled(by: requestComponents) }),
                let (response, delay) = await responseGenerator.response(for: requestComponents),
                await incrementResponseCounterAndSleep(for: delay)
            else {
                return nil
            }

            return try response.get()
        }


        private func evaluateRequestConditions(with requestComponents: RequestComponents) -> Bool {
            simulatedURLRequestLoaderLogger.debug(
                "Evaluating if \(String(describing: requestComponents)) satisfy request conditions"
            )

            for condition in requestConditions {
                let isFulfilled = condition.isFulfilled(by: requestComponents)
                simulatedURLRequestLoaderLogger.debug(
                    "  - \(String(describing: condition)): \(isFulfilled ? "fulfilled" : "not fulfilled", privacy: .public)"
                )

                if !isFulfilled {
                    return false
                }
            }

            return true
        }


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
