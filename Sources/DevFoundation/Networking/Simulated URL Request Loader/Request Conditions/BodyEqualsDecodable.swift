//
//  BodyEqualsDecodable.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/24/25.
//

import Foundation

extension SimulatedURLRequestLoader.RequestConditions {
    public struct BodyEqualsDecodable<Body>: SimulatedURLRequestLoader.RequestCondition
    where Body: Decodable & Equatable & Sendable {
        public let body: Body
        public let decoder: any TopLevelDecoder<Data> & Sendable


        public init(body: Body, decoder: any TopLevelDecoder<Data> & Sendable) {
            self.body = body
            self.decoder = decoder
        }


        public func isFulfilled(by requestComponents: SimulatedURLRequestLoader.RequestComponents) -> Bool {
            guard let decodedBody = try? decoder.decode(Body.self, from: requestComponents.body) else {
                return false
            }

            return decodedBody == body
        }


        public var description: String {
            return ".bodyEquals(\(body), decoder: \(decoder))"
        }
    }
}


extension SimulatedURLRequestLoader.RequestCondition
where Self == SimulatedURLRequestLoader.RequestConditions.AnyRequestCondition {
    public static func bodyEquals<Body>(
        _ body: Body,
        decoder: any TopLevelDecoder<Data> & Sendable = JSONDecoder()
    ) -> SimulatedURLRequestLoader.RequestConditions.BodyEqualsDecodable<Body>
    where Body: Decodable & Equatable & Sendable {
        .init(body: body, decoder: decoder)
    }
}
