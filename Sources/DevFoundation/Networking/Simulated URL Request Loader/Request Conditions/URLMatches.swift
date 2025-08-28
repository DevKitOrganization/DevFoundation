//
//  URLMatches.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/25/25.
//

import Foundation

extension SimulatedURLRequestLoader.RequestConditions {
    public struct URLMatches: SimulatedURLRequestLoader.RequestCondition {
        nonisolated(unsafe) public let urlRegex: Regex<AnyRegexOutput>


        public init<Output>(urlRegex: sending Regex<Output>) {
            self.urlRegex = Regex(urlRegex)
        }


        public func isFulfilled(by requestComponents: SimulatedURLRequestLoader.RequestComponents) -> Bool {
            return (try? urlRegex.wholeMatch(in: requestComponents.url.absoluteString)) != nil
        }


        public var description: String {
            return ".urlMatches(\(urlRegex))"
        }
    }
}


extension SimulatedURLRequestLoader.RequestCondition
where Self == SimulatedURLRequestLoader.RequestConditions.URLMatches {
    public static func urlEquals(_ url: URL) -> Self {
        .init(urlRegex: Regex<Void>(verbatim: url.absoluteString))
    }


    public static func urlMatches<Output>(_ urlPattern: sending Regex<Output>) -> Self {
        .init(urlRegex: urlPattern)
    }
}
