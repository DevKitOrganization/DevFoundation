//
//  LiveQueryResultsProducer.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 10/23/2025.
//

import Foundation

/// A type that produces results for query fragments.
///
/// Conform to this protocol to define how results are generated or fetched for a given query fragment. ``LiveQuery``
/// uses result producers to fetch results and determine how to schedule result production.
public protocol LiveQueryResultsProducer<Results>: Sendable {
    /// The type of results that instances produce.
    associatedtype Results: Sendable

    /// The strategy used to schedule result production.
    var schedulingStrategy: LiveQuerySchedulingStrategy { get }

    /// Returns a canonical form of the query fragment, or `nil` if it’s invalid.
    ///
    /// Conforming types can use this function to sanitize or validate query fragments before producing results. The
    /// default implementation trims whitespace, collapses multiple spaces into one, and returns `nil` for empty
    /// strings.
    ///
    /// - Parameter queryFragment: The query fragment to canonicalize.
    func canonicalQueryFragment(from queryFragment: String) -> String?

    /// Produces results for the specified query fragment.
    ///
    /// - Parameter queryFragment: A canonical query fragment. Live queries ensure this is already canonicalized before
    ///   calling this function.
    func results(forQueryFragment queryFragment: String) async throws -> Results
}


extension LiveQueryResultsProducer {
    public func canonicalQueryFragment(from queryFragment: String) -> String? {
        let canonicalFragment = queryFragment.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        return canonicalFragment.isEmpty ? nil : canonicalFragment
    }
}
