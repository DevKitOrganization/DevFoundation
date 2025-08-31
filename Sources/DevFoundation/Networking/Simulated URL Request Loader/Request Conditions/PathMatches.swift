//
//  PathMatches.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/25/25.
//

import Foundation

extension SimulatedURLRequestLoader.RequestConditions {
    /// A request condition that is fulfilled if a request’s path matches a given regular expression.
    public struct PathMatches: SimulatedURLRequestLoader.RequestCondition {
        /// The regular expression that a request’s path must match for this condition to be fulfilled.
        nonisolated(unsafe) public let pattern: Regex<AnyRegexOutput>

        /// Whether to use the percent-encoded form of the path when matching.
        public let percentEncoded: Bool


        /// Creates a new `PathMatches` condition with the specified path regex and percent encoding option.
        ///
        /// You should generally use ``SimulatedURLRequestLoader/RequestCondition/pathEquals(_:percentEncoded:)`` or
        /// ``SimulatedURLRequestLoader/RequestCondition/pathMatches(_:percentEncoded:)`` to create instances
        /// of this type.
        ///
        /// - Parameters:
        ///   - pattern: The regular expression that a request’s path must match for the condition to be fulfilled.
        ///   - percentEncoded: Whether to use the percent-encoded form of the path when matching.
        public init<Output>(pattern: Regex<Output>, percentEncoded: Bool) {
            self.pattern = Regex(pattern)
            self.percentEncoded = percentEncoded
        }


        public func isFulfilled(by requestComponents: SimulatedURLRequestLoader.RequestComponents) -> Bool {
            let path = requestComponents.url.path(percentEncoded: percentEncoded)
            return (try? pattern.wholeMatch(in: path)) != nil
        }


        public var description: String {
            return ".pathMatches(*****, percentEncoded: \(percentEncoded))"
        }
    }
}


extension SimulatedURLRequestLoader.RequestCondition
where Self == SimulatedURLRequestLoader.RequestConditions.PathMatches {
    /// Creates a new request condition that is fulfilled when a request’s path equals a given path.
    ///
    /// - Parameters:
    ///   - path: The path that a request’s path must equal for the condition to be fulfilled.
    ///   - percentEncoded: Whether to use the percent-encoded form of the path when matching.
    /// - Returns: The new request condition.
    public static func pathEquals(_ path: String, percentEncoded: Bool) -> Self {
        .init(pattern: Regex<Void>(verbatim: path), percentEncoded: percentEncoded)
    }


    /// Creates a new request condition that is fulfilled when a request’s path matches a given regex pattern.
    ///
    /// - Parameters:
    ///   - pattern: The regular expression pattern that a request’s path must match for the condition
    ///     to be fulfilled.
    ///   - percentEncoded: Whether to use the percent-encoded form of the path when matching.
    /// - Returns: The new request condition.
    public static func pathMatches<Output>(_ pattern: sending Regex<Output>, percentEncoded: Bool) -> Self {
        .init(pattern: pattern, percentEncoded: percentEncoded)
    }
}
