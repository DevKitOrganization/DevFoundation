//
//  RequestCondition.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/17/25.
//

import Foundation
import os.log

extension SimulatedURLRequestLoader {
    /// A type describing a condition that must be satisfied for a responder to handle a request.
    ///
    /// Request conditions provide a flexible way to match incoming requests based on various criteria such as HTTP
    /// method, URL patterns, headers, or body content. When a request is processed, all conditions associated with a
    /// responder must return `true` from ``isFulfilled(by:)`` for that responder to generate a response.
    ///
    /// DevFoundation provides many built-in request conditions through ``RequestConditions``, but you can create custom
    /// conditions by conforming to this protocol. When creating your own conditions, there are a couple conventions
    /// that we strongly recommend:
    ///
    ///   1. Nest your type inside ``RequestConditions``.
    ///   2. Extend ``RequestCondition`` to include one or more static factory functions to create an instance of your
    ///      condition.
    ///
    /// For example, suppose we want a request condition that checks that the URL fragment is one of several allowed
    /// values:
    ///
    ///     extension SimulatedURLRequestLoader.RequestConditions {
    ///         struct FragmentIsOneOf: SimulatedURLRequestLoader.RequestCondition {
    ///             let fragments: Set<String>
    ///
    ///
    ///             func isFulfilled(by requestComponents: RequestComponents) -> Bool {
    ///                 return fragments.contains(requestComponents.urlComponents.fragment ?? "")
    ///             }
    ///
    ///
    ///             var description: String {
    ///                 return "fragment(isOneOf: \(fragments))"
    ///             }
    ///         }
    ///     }
    ///
    /// Note that we implemented the `description` computed property. This is required for all request conditions to
    /// enable better logging during condition evaluation. Next, we need to create our static factory functions:
    ///
    ///     extension SimulatedURLRequestLoader.RequestCondition
    ///     where Self == SimulatedURLRequestLoader.RequestConditions.FragmentIsOneOf {
    ///         public static func fragmentEquals(_ fragment: String) -> Self {
    ///             .init(fragments: [fragment])
    ///         }
    ///
    ///
    ///         public static func fragment(isOneOf fragments: Set<String>) -> Self {
    ///             .init(fragments: fragments)
    ///         }
    ///     }
    public protocol RequestCondition: CustomStringConvertible, Sendable {
        /// Returns whether this condition is fulfilled by the given request components.
        ///
        /// - Parameter requestComponents: The components of the request to evaluate.
        /// - Returns: `true` if the condition is fulfilled, `false` otherwise.
        func isFulfilled(by requestComponents: RequestComponents) -> Bool
    }
}


extension SimulatedURLRequestLoader {
    /// A namespace for types that serve as request conditions.
    public enum RequestConditions {}
}
