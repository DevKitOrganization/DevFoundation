//
//  QueryItemsContains.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/25/25.
//

import Foundation

extension SimulatedURLRequestLoader.RequestConditions {
    /// A request condition that is fulfilled if a request’s query items contain a given query item.
    public struct QueryItemsContains: SimulatedURLRequestLoader.RequestCondition {
        /// The query item that a request’s query items must contain for the condition to be fulfilled.
        public let queryItem: URLQueryItem


        /// Creates a new `QueryItemsContains` condition with the specified query item.
        ///
        /// You should generally use ``SimulatedURLRequestLoader/RequestCondition/queryItemsContains(_:)`` to create
        /// instances of this type.
        ///
        /// - Parameter queryItem: The query item that a request’s query items must contain for the condition
        ///   to be fulfilled.
        public init(queryItem: URLQueryItem) {
            self.queryItem = queryItem
        }


        public func isFulfilled(by requestComponents: SimulatedURLRequestLoader.RequestComponents) -> Bool {
            return requestComponents.urlComponents.queryItems?.contains(queryItem) ?? false
        }


        public var description: String {
            return ".queryItemsContains(\(queryItem))"
        }
    }
}


extension SimulatedURLRequestLoader.RequestCondition
where Self == SimulatedURLRequestLoader.RequestConditions.QueryItemsContains {
    /// Creates a new request condition that is fulfilled when a request’s query items contain a given query item.
    ///
    /// - Parameter queryItem: The query item that a request’s query items must contain for the condition
    ///   to be fulfilled.
    /// - Returns: The new request condition.
    public static func queryItemsContains(_ queryItem: URLQueryItem) -> Self {
        .init(queryItem: queryItem)
    }
}
