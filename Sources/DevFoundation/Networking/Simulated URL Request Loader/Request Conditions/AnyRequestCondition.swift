//
//  AnyRequestCondition.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/25/25.
//

import Foundation

extension SimulatedURLRequestLoader.RequestConditions {
    public struct AnyRequestCondition: SimulatedURLRequestLoader.RequestCondition {
        public let base: any SimulatedURLRequestLoader.RequestCondition


        public init(_ base: any SimulatedURLRequestLoader.RequestCondition) {
            self.base = base
        }


        public func isFulfilled(by requestComponents: SimulatedURLRequestLoader.RequestComponents) -> Bool {
            return base.isFulfilled(by: requestComponents)
        }


        public var description: String {
            String(describing: base)
        }
    }
}
