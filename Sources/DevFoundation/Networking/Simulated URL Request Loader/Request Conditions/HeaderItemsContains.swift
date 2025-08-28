//
//  HeaderItemsContains.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/24/25.
//

import Foundation

extension SimulatedURLRequestLoader.RequestConditions {
    public struct HeaderItemsContains: SimulatedURLRequestLoader.RequestCondition {
        public let headerItem: HTTPHeaderItem


        public init(headerItem: HTTPHeaderItem) {
            self.headerItem = headerItem
        }


        public func isFulfilled(by requestComponents: SimulatedURLRequestLoader.RequestComponents) -> Bool {
            return requestComponents.headerItems.contains(headerItem)
        }


        public var description: String {
            return ".headerItemsContains(\(headerItem))"
        }
    }
}


extension SimulatedURLRequestLoader.RequestCondition
where Self == SimulatedURLRequestLoader.RequestConditions.HeaderItemsContains {
    public static func headerItemsContains(_ headerItem: HTTPHeaderItem) -> Self {
        .init(headerItem: headerItem)
    }
}
