//
//  HTTPMethodIsOneOf.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/24/25.
//

import Foundation

extension SimulatedURLRequestLoader.RequestConditions {
    /// A request condition that is fulfilled if a request’s HTTP method is one of a given set of HTTP methods.
    public struct HTTPMethodIsOneOf: SimulatedURLRequestLoader.RequestCondition, Hashable {
        /// The HTTP methods, one of which a request’s HTTP method must equal for the condition to be fulfilled.
        public let httpMethods: Set<HTTPMethod>


        /// Creates a new `HTTPMethodIsOneOf` condition with the specified HTTP methods.
        ///
        /// You should generally use ``SimulatedURLRequestLoader/RequestCondition/httpMethodEquals(_:)`` or
        /// ``SimulatedURLRequestLoader/RequestCondition/httpMethod(isOneOf:)`` to create instances of this type.
        ///
        /// - Parameter httpMethods: The HTTP methods, one of which a request’s HTTP method must equal for the
        ///   condition to be fulfilled.
        public init(httpMethods: Set<HTTPMethod>) {
            self.httpMethods = httpMethods
        }


        public func isFulfilled(by requestComponents: SimulatedURLRequestLoader.RequestComponents) -> Bool {
            return httpMethods.contains(requestComponents.httpMethod)
        }


        public var description: String {
            return ".httpMethod(isOneOf: \(httpMethods.map(\.rawValue)))"
        }
    }
}


extension SimulatedURLRequestLoader.RequestCondition
where Self == SimulatedURLRequestLoader.RequestConditions.HTTPMethodIsOneOf {
    /// Creates a new request condition that is fulfilled when a request’s HTTP method equals a given HTTP method.
    ///
    /// - Parameter httpMethod: The HTTP method that a request’s HTTP method must equal for the condition
    ///   to be fulfilled.
    /// - Returns: The new request condition.
    public static func httpMethodEquals(_ httpMethod: HTTPMethod) -> Self {
        .init(httpMethods: [httpMethod])
    }


    /// Creates a new request condition that is fulfilled when a request’s HTTP method is one of a given set.
    ///
    /// - Parameter httpMethods: The HTTP methods, one of which a request’s HTTP method must equal for the
    ///   condition to be fulfilled.
    /// - Returns: The new request condition.
    public static func httpMethod(isOneOf httpMethods: Set<HTTPMethod>) -> Self {
        .init(httpMethods: httpMethods)
    }
}
