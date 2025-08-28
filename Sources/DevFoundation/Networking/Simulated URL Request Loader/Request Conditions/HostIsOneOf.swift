//
//  HostIsOneOf.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/24/25.
//

import Foundation

extension SimulatedURLRequestLoader.RequestConditions {
    public struct HostIsOneOf: SimulatedURLRequestLoader.RequestCondition {
        public let hosts: Set<String>


        public init(hosts: Set<String>) {
            self.hosts = hosts
        }


        public func isFulfilled(by requestComponents: SimulatedURLRequestLoader.RequestComponents) -> Bool {
            return hosts.contains(requestComponents.urlComponents.host ?? "")
        }


        public var description: String {
            return ".hostIsOneOf(\(hosts))"
        }
    }
}


extension SimulatedURLRequestLoader.RequestCondition
where Self == SimulatedURLRequestLoader.RequestConditions.HostIsOneOf {
    public static func hostEquals(_ host: String) -> Self {
        .init(hosts: [host])
    }


    public static func hostIsOneOf(_ hosts: Set<String>) -> Self {
        .init(hosts: hosts)
    }
}
