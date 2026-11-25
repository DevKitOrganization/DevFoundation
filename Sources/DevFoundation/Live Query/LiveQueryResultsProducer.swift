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
///
/// Results producers are result updates producers whose result updates contain a single value: the results returned by
/// ``results(forQueryFragment:)``. If a query fragment’s results can change after they’re produced, conform to
/// ``LiveQueryResultUpdatesProducer`` instead.
public protocol LiveQueryResultsProducer<Results>: LiveQueryResultUpdatesProducer {
    /// The type of results that instances produce.
    associatedtype Results

    /// Produces results for the specified query fragment.
    ///
    /// - Parameter queryFragment: A canonical query fragment. Live queries ensure this is already canonicalized before
    ///   calling this function.
    func results(forQueryFragment queryFragment: String) async throws -> Results
}


extension LiveQueryResultsProducer {
    /// Returns a sequence that produces the query fragment’s results once.
    ///
    /// The sequence calls ``results(forQueryFragment:)`` when it’s first iterated, produces its results, and then
    /// finishes. If the iterating task is cancelled before the sequence calls ``results(forQueryFragment:)``, the
    /// sequence throws a `CancellationError` instead. Otherwise, cancelling the iterating task cancels the call.
    ///
    /// - Parameter queryFragment: A canonical query fragment. Live queries ensure this is already canonicalized before
    ///   calling this function.
    public func resultUpdates(
        forQueryFragment queryFragment: String
    ) -> some AsyncSequence<Results, any Error> & Sendable {
        return OneShotLiveQueryResultUpdates(resultsProducer: self, queryFragment: queryFragment)
    }
}
