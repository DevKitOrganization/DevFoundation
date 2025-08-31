//
//  HeaderItemsEquals.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/24/25.
//

import Foundation

extension SimulatedURLRequestLoader.RequestConditions {
    /// A request condition that is fulfilled if a request’s header items are equal to a given set of header items.
    public struct HeaderItemsEquals: SimulatedURLRequestLoader.RequestCondition {
        /// The header items that a request’s header items must equal for the condition to be fulfilled.
        public let headerItems: Set<HTTPHeaderItem>


        /// Creates a new `HeaderItemsEquals` condition with the specified header items.
        ///
        /// You should generally use ``SimulatedURLRequestLoader/RequestCondition/headerItemsEquals(_:)`` to create
        /// instances of this type.
        ///
        /// - Parameter headerItems: The header items that a request’s header items must equal for the condition
        ///   to be fulfilled.
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
    /// Creates a new request condition that is fulfilled when a request’s header items are equal to a given set.
    ///
    /// - Parameter headerItems: The header items that a request’s header items must equal for the condition
    ///   to be fulfilled.
    /// - Returns: The new request condition.
    public static func headerItemsEquals(_ headerItems: Set<HTTPHeaderItem>) -> Self {
        .init(headerItems: headerItems)
    }
}
