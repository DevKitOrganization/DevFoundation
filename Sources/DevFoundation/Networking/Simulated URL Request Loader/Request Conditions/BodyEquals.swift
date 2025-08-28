//
//  BodyEquals.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/24/25.
//

import Foundation

extension SimulatedURLRequestLoader.RequestConditions {
    public struct BodyEquals: SimulatedURLRequestLoader.RequestCondition {
        public let body: Data


        public init(body: Data) {
            self.body = body
        }


        public func isFulfilled(by requestComponents: SimulatedURLRequestLoader.RequestComponents) -> Bool {
            return requestComponents.body == body
        }


        public var description: String {
            return ".bodyEquals(\(body))"
        }
    }
}


extension SimulatedURLRequestLoader.RequestCondition
where Self == SimulatedURLRequestLoader.RequestConditions.BodyEquals {
    public static func bodyEquals(_ body: Data) -> Self {
        .init(body: body)
    }
}
