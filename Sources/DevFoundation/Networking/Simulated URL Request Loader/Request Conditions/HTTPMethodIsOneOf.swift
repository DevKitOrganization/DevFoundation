//
//  HTTPMethodIsOneOf.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/24/25.
//

import Foundation

extension SimulatedURLRequestLoader.RequestConditions {
    public struct HTTPMethodIsOneOf: SimulatedURLRequestLoader.RequestCondition {
        public let httpMethods: Set<HTTPMethod>


        public init(httpMethods: Set<HTTPMethod>) {
            self.httpMethods = httpMethods
        }


        public func isFulfilled(by requestComponents: SimulatedURLRequestLoader.RequestComponents) -> Bool {
            return httpMethods.contains(requestComponents.httpMethod)
        }


        public var description: String {
            return ".httpMethodIsOneOf(\(httpMethods))"
        }
    }
}


extension SimulatedURLRequestLoader.RequestCondition
where Self == SimulatedURLRequestLoader.RequestConditions.HTTPMethodIsOneOf {
    public static func httpMethodEquals(_ httpMethod: HTTPMethod) -> Self {
        .init(httpMethods: [httpMethod])
    }


    public static func httpMethodIsOneOf(_ httpMethods: Set<HTTPMethod>) -> Self {
        .init(httpMethods: httpMethods)
    }
}
