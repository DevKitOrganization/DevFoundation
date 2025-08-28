//
//  SchemeIsOneOf.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/24/25.
//

import Foundation

extension SimulatedURLRequestLoader.RequestConditions {
    public struct SchemeIsOneOf: SimulatedURLRequestLoader.RequestCondition {
        public let schemes: Set<String>


        public init(schemes: Set<String>) {
            self.schemes = schemes
        }


        public func isFulfilled(by requestComponents: SimulatedURLRequestLoader.RequestComponents) -> Bool {
            return schemes.contains(requestComponents.urlComponents.scheme ?? "")
        }


        public var description: String {
            return ".schemeIsOneOf(\(schemes))"
        }
    }
}


extension SimulatedURLRequestLoader.RequestCondition
where Self == SimulatedURLRequestLoader.RequestConditions.SchemeIsOneOf {
    public static func schemeEquals(_ scheme: String) -> Self {
        .init(schemes: [scheme])
    }


    public static func schemeIsOneOf(_ schemes: Set<String>) -> Self {
        .init(schemes: schemes)
    }
}
