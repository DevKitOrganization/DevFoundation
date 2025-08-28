//
//  QueryItemsContains.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/25/25.
//

import Foundation

extension SimulatedURLRequestLoader.RequestConditions {
    public struct QueryItemsContains: SimulatedURLRequestLoader.RequestCondition {
        public let queryItem: URLQueryItem


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
    public static func queryItemsContains(_ queryItem: URLQueryItem) -> Self {
        .init(queryItem: queryItem)
    }
}
