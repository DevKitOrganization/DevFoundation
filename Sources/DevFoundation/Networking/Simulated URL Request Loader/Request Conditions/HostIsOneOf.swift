//
//  HostIsOneOf.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/24/25.
//

import Foundation

extension SimulatedURLRequestLoader.RequestConditions {
    /// A request condition that is fulfilled if a request’s host is one of a given set of hosts.
    public struct HostIsOneOf: SimulatedURLRequestLoader.RequestCondition {
        /// The hosts, one of which a request’s host must equal for the condition to be fulfilled.
        public let hosts: Set<String>


        /// Creates a new `HostIsOneOf` condition with the specified hosts.
        ///
        /// You should generally use ``SimulatedURLRequestLoader/RequestCondition/hostEquals(_:)`` or
        /// ``SimulatedURLRequestLoader/RequestCondition/host(isOneOf:)`` to create instances of this type.
        ///
        /// - Parameter hosts: The hosts, one of which a request’s host must equal for the condition to be fulfilled.
        public init(hosts: Set<String>) {
            self.hosts = hosts
        }


        public func isFulfilled(by requestComponents: SimulatedURLRequestLoader.RequestComponents) -> Bool {
            return hosts.contains(requestComponents.urlComponents.host ?? "")
        }


        public var description: String {
            return ".host(isOneOf: \(hosts))"
        }
    }
}


extension SimulatedURLRequestLoader.RequestCondition
where Self == SimulatedURLRequestLoader.RequestConditions.HostIsOneOf {
    /// Creates a new request condition that is fulfilled when a request’s host equals a given host.
    ///
    /// - Parameter host: The host that a request’s host must equal for the condition to be fulfilled.
    /// - Returns: The new request condition.
    public static func hostEquals(_ host: String) -> Self {
        .init(hosts: [host])
    }


    /// Creates a new request condition that is fulfilled when a request’s host is one of a given set of hosts.
    ///
    /// - Parameter hosts: The hosts, one of which a request’s host must equal for the condition to be fulfilled.
    /// - Returns: The new request condition.
    public static func host(isOneOf hosts: Set<String>) -> Self {
        .init(hosts: hosts)
    }
}
