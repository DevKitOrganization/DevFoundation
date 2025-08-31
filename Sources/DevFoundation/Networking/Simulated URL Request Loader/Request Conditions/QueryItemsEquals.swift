//
//  QueryItemsEquals.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/25/25.
//

import Foundation

extension SimulatedURLRequestLoader.RequestConditions {
    /// A request condition that is fulfilled if a request’s query items are equal to a given array of query items.
    public struct QueryItemsEquals: SimulatedURLRequestLoader.RequestCondition {
        /// The query items that a request’s query items must equal for the condition to be fulfilled.
        public let queryItems: [URLQueryItem]


        /// Creates a new `QueryItemsEquals` condition with the specified query items.
        ///
        /// You should generally use ``SimulatedURLRequestLoader/RequestCondition/queryItemsEquals(_:)`` to create
        /// instances of this type.
        ///
        /// - Parameter queryItems: The query items that a request’s query items must equal for the condition
        ///   to be fulfilled.
        public init(queryItems: [URLQueryItem]) {
            self.queryItems = queryItems
        }


        public func isFulfilled(by requestComponents: SimulatedURLRequestLoader.RequestComponents) -> Bool {
            return requestComponents.urlComponents.queryItems == queryItems
        }


        public var description: String {
            return ".queryItemsEquals(\(queryItems))"
        }
    }
}


extension SimulatedURLRequestLoader.RequestCondition
where Self == SimulatedURLRequestLoader.RequestConditions.QueryItemsEquals {
    /// Creates a new request condition that is fulfilled when a request’s query items are equal to a given array.
    ///
    /// - Parameter queryItems: The query items that a request’s query items must equal for the condition
    ///   to be fulfilled.
    /// - Returns: The new request condition.
    public static func queryItemsEquals(_ queryItems: [URLQueryItem]) -> Self {
        .init(queryItems: queryItems)
    }
}
