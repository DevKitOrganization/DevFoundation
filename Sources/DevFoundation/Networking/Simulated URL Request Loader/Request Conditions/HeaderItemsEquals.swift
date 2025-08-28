//
//  HeaderItemsEquals.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/24/25.
//

import Foundation

extension SimulatedURLRequestLoader.RequestConditions {
    public struct HeaderItemsEquals: SimulatedURLRequestLoader.RequestCondition {
        public let headerItems: Set<HTTPHeaderItem>


        public init(headerItems: Set<HTTPHeaderItem>) {
            self.headerItems = headerItems
        }


        public func isFulfilled(by requestComponents: SimulatedURLRequestLoader.RequestComponents) -> Bool {
            return requestComponents.headerItems == headerItems
        }


        public var description: String {
            return ".headerItemsEquals(\(headerItems))"

        }
    }
}


extension SimulatedURLRequestLoader.RequestCondition
where Self == SimulatedURLRequestLoader.RequestConditions.HeaderItemsEquals {
    public static func headerItemsEquals(_ headerItems: Set<HTTPHeaderItem>) -> Self {
        .init(headerItems: headerItems)
    }
}
