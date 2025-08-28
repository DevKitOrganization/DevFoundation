//
//  PathMatches.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/25/25.
//

import Foundation

extension SimulatedURLRequestLoader.RequestConditions {
    public struct PathMatches: SimulatedURLRequestLoader.RequestCondition {
        nonisolated(unsafe) public let pathRegex: Regex<AnyRegexOutput>
        public let percentEncoded: Bool


        public init<Output>(pathRegex: sending Regex<Output>, percentEncoded: Bool) {
            self.pathRegex = Regex(pathRegex)
            self.percentEncoded = percentEncoded
        }


        public func isFulfilled(by requestComponents: SimulatedURLRequestLoader.RequestComponents) -> Bool {
            let path = requestComponents.url.path(percentEncoded: percentEncoded)
            return (try? pathRegex.wholeMatch(in: path)) != nil
        }


        public var description: String {
            return ".pathMatches(\(pathRegex), percentEncoded: \(percentEncoded))"
        }
    }
}


extension SimulatedURLRequestLoader.RequestCondition
where Self == SimulatedURLRequestLoader.RequestConditions.PathMatches {
    public static func pathEquals(_ path: String, percentEncoded: Bool) -> Self {
        .init(pathRegex: Regex<Void>(verbatim: path), percentEncoded: percentEncoded)
    }


    public static func pathMatches<Output>(_ pathPattern: sending Regex<Output>, percentEncoded: Bool) -> Self {
        .init(pathRegex: pathPattern, percentEncoded: percentEncoded)
    }
}
