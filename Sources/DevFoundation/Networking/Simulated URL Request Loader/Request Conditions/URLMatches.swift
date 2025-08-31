//
//  URLMatches.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/25/25.
//

import Foundation

extension SimulatedURLRequestLoader.RequestConditions {
    /// A request condition that is fulfilled if a request’s URL matches a given regular expression.
    public struct URLMatches: SimulatedURLRequestLoader.RequestCondition {
        /// The regular expression that a request’s URL must match for this condition to be fulfilled.
        nonisolated(unsafe) public let pattern: Regex<AnyRegexOutput>


        /// Creates a new `URLMatches` condition with the specified URL regex.
        ///
        /// You should generally use ``SimulatedURLRequestLoader/RequestCondition/urlEquals(_:)`` or
        /// ``SimulatedURLRequestLoader/RequestCondition/urlMatches(_:)`` to create instances of this type.
        ///
        /// - Parameter pattern: The regular expression that a request’s URL must match for the condition to be
        ///   fulfilled.
        public init<Output>(pattern: sending Regex<Output>) {
            self.pattern = Regex(pattern)
        }


        public func isFulfilled(by requestComponents: SimulatedURLRequestLoader.RequestComponents) -> Bool {
            return (try? pattern.wholeMatch(in: requestComponents.url.absoluteString)) != nil
        }


        public var description: String {
            return ".urlMatches(*****)"
        }
    }
}


extension SimulatedURLRequestLoader.RequestCondition
where Self == SimulatedURLRequestLoader.RequestConditions.URLMatches {
    /// Creates a new request condition that is fulfilled when a request’s URL equals a given URL.
    ///
    /// - Parameter url: The URL that a request’s URL must equal for the condition to be fulfilled.
    /// - Returns: The new request condition.
    public static func urlEquals(_ url: URL) -> Self {
        .init(pattern: Regex<Void>(verbatim: url.absoluteString))
    }


    /// Creates a new request condition that is fulfilled when a request’s URL matches a given regex pattern.
    ///
    /// - Parameter pattern: The regular expression pattern that a request’s URL must match for the
    ///   condition to be fulfilled.
    /// - Returns: The new request condition.
    public static func urlMatches<Output>(_ pattern: sending Regex<Output>) -> Self {
        .init(pattern: pattern)
    }
}
