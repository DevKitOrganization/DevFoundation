//
//  HeaderItemsContains.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/24/25.
//

import Foundation

extension SimulatedURLRequestLoader.RequestConditions {
    /// A request condition that is fulfilled if a request’s header items contain a given header item.
    public struct HeaderItemsContains: SimulatedURLRequestLoader.RequestCondition {
        /// The header item that a request’s header items must contain for the condition to be fulfilled.
        public let headerItem: HTTPHeaderItem


        /// Creates a new `HeaderItemsContains` condition with the specified header item.
        ///
        /// You should generally use ``SimulatedURLRequestLoader/RequestCondition/headerItemsContains(_:)`` to create
        /// instances of this type.
        ///
        /// - Parameter headerItem: The header item that a request’s header items must contain for the condition to be
        ///   fulfilled.
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
    /// Creates a new request condition that is fulfilled when a request’s header items contain a given header item.
    ///
    /// - Parameter headerItem: The header item that a request’s header items must contain for the condition to be
    ///   fulfilled.
    /// - Returns: The new request condition.
    public static func headerItemsContains(_ headerItem: HTTPHeaderItem) -> Self {
        .init(headerItem: headerItem)
    }
}
