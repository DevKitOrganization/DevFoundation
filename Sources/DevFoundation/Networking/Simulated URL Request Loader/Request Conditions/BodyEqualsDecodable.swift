//
//  BodyEqualsDecodable.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/24/25.
//

import Foundation

extension SimulatedURLRequestLoader.RequestConditions {
    /// A request condition that is fulfilled if a request’s body, when decoded, is equal to a given value.
    public struct BodyEqualsDecodable<Body>: SimulatedURLRequestLoader.RequestCondition
    where Body: Decodable & Equatable & Sendable {
        /// The decoded value that a request’s body must equal for the condition to be fulfilled.
        public let body: Body

        /// The decoder used to decode the request’s body data.
        public let decoder: any TopLevelDecoder<Data> & Sendable


        /// Creates a new `BodyEqualsDecodable` condition with the specified body and decoder.
        ///
        /// You should generally use ``SimulatedURLRequestLoader/RequestCondition/bodyEquals(_:decoder:)`` to create
        /// instances of this type.
        ///
        /// - Parameters:
        ///   - body: The decoded value that a request’s body must equal for the condition to be fulfilled.
        ///   - decoder: The decoder used to decode the request’s body data.
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
    /// Creates a new request condition that is fulfilled when a request’s decoded body is equal to a given value.
    ///
    /// - Parameters:
    ///   - body: The decoded value that a request’s body must equal for the condition to be fulfilled.
    ///   - decoder: The decoder used to decode the request’s body data. Defaults to `JSONDecoder()`.
    /// - Returns: The new request condition.
    public static func bodyEquals<Body>(
        _ body: Body,
        decoder: any TopLevelDecoder<Data> & Sendable = JSONDecoder()
    ) -> Self
    where Body: Decodable & Equatable & Sendable {
        return .init(
            SimulatedURLRequestLoader.RequestConditions.BodyEqualsDecodable(
                body: body,
                decoder: decoder
            )
        )
    }
}
