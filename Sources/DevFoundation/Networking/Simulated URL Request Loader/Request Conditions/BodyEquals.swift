//
//  BodyEquals.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/24/25.
//

import Foundation

extension SimulatedURLRequestLoader.RequestConditions {
    /// A request condition that is fulfilled if a request’s body is equal to a given value.
    public struct BodyEquals: SimulatedURLRequestLoader.RequestCondition {
        /// The data value that a request’s body must equal for the condition to be fulfilled.
        public let body: Data


        /// Creates a new `BodyEquals` condition with the specified body.
        ///
        /// You should generally use ``SimulatedURLRequestLoader/RequestCondition/bodyEquals(_:)`` to create instances
        /// of this type.
        ///
        /// - Parameter body: The data value that a request’s body must equal for the condition to be fulfilled.
        public init(body: Data) {
            self.body = body
        }


        public func isFulfilled(by requestComponents: SimulatedURLRequestLoader.RequestComponents) -> Bool {
            return requestComponents.body == body
        }


        public var description: String {
            return ".bodyEquals(\(body))"
        }
    }
}


extension SimulatedURLRequestLoader.RequestCondition
where Self == SimulatedURLRequestLoader.RequestConditions.BodyEquals {
    /// Creates a new request condition that is fulfilled when a request’s body is equal to a given value.
    ///
    /// - Parameter body: The data value that a request’s body must equal for the condition to be fulfilled.
    /// - Returns: The new request condition.
    public static func bodyEquals(_ body: Data) -> Self {
        .init(body: body)
    }
}
