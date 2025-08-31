//
//  SchemeIsOneOf.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/24/25.
//

import Foundation

extension SimulatedURLRequestLoader.RequestConditions {
    /// A request condition that is fulfilled if a request’s scheme is one of a given set of schemes.
    public struct SchemeIsOneOf: SimulatedURLRequestLoader.RequestCondition {
        /// The schemes, one of which a request’s scheme must equal for the condition to be fulfilled.
        public let schemes: Set<String>


        /// Creates a new `SchemeIsOneOf` condition with the specified schemes.
        ///
        /// You should generally use ``SimulatedURLRequestLoader/RequestCondition/schemeEquals(_:)`` or
        /// ``SimulatedURLRequestLoader/RequestCondition/scheme(isOneOf:)`` to create instances of this type.
        ///
        /// - Parameter schemes: The schemes, one of which a request’s scheme must equal for the condition
        ///   to be fulfilled.
        public init(schemes: Set<String>) {
            self.schemes = schemes
        }


        public func isFulfilled(by requestComponents: SimulatedURLRequestLoader.RequestComponents) -> Bool {
            return schemes.contains(requestComponents.urlComponents.scheme ?? "")
        }


        public var description: String {
            return ".scheme(isOneOf: \(schemes))"
        }
    }
}


extension SimulatedURLRequestLoader.RequestCondition
where Self == SimulatedURLRequestLoader.RequestConditions.SchemeIsOneOf {
    /// Creates a new request condition that is fulfilled when a request’s scheme equals a given scheme.
    ///
    /// - Parameter scheme: The scheme that a request’s scheme must equal for the condition to be fulfilled.
    /// - Returns: The new request condition.
    public static func schemeEquals(_ scheme: String) -> Self {
        .init(schemes: [scheme])
    }


    /// Creates a new request condition that is fulfilled when a request’s scheme is one of a given set.
    ///
    /// - Parameter schemes: The schemes, one of which a request’s scheme must equal for the condition
    ///   to be fulfilled.
    /// - Returns: The new request condition.
    public static func scheme(isOneOf schemes: Set<String>) -> Self {
        .init(schemes: schemes)
    }
}
