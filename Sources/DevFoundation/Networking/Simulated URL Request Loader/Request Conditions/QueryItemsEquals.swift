//
//  QueryItemsEquals.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/25/25.
//

import Foundation

extension SimulatedURLRequestLoader.RequestConditions {
    public struct QueryItemsEquals: SimulatedURLRequestLoader.RequestCondition {
        public let queryItems: [URLQueryItem]


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
    public static func queryItemsEquals(_ queryItems: [URLQueryItem]) -> Self {
        .init(queryItems: queryItems)
    }
}
