//
//  AnyRequestCondition.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/25/25.
//

import Foundation

extension SimulatedURLRequestLoader.RequestConditions {
    /// A type-erased request condition.
    ///
    /// This type exists so that request condition types with generic parameters can still declare static factory
    /// functions in an extension on `RequestCondition`. For example, ``BodyEqualsDecodable`` declares its factory
    /// function as follows:
    ///
    ///     extension SimulatedURLRequestLoader.RequestCondition
    ///     where Self == SimulatedURLRequestLoader.RequestConditions.AnyRequestCondition {
    ///         public static func bodyEquals<Body>(
    ///             _ body: Body,
    ///             decoder: any TopLevelDecoder<Data> & Sendable = JSONDecoder()
    ///         ) -> Self
    ///         where Body: Decodable & Equatable & Sendable {
    ///             ...
    ///         }
    ///     }
    public struct AnyRequestCondition: SimulatedURLRequestLoader.RequestCondition {
        /// The request condition whose type this instance is erasing.
        public let base: any SimulatedURLRequestLoader.RequestCondition


        /// Creates a new request condition that erases the type of the specified condition.
        /// - Parameter base: The request condition whose type this instance is erasing.
        public init(_ base: any SimulatedURLRequestLoader.RequestCondition) {
            self.base = base
        }


        public func isFulfilled(by requestComponents: SimulatedURLRequestLoader.RequestComponents) -> Bool {
            return base.isFulfilled(by: requestComponents)
        }


        public var description: String {
            String(describing: base)
        }
    }
}
