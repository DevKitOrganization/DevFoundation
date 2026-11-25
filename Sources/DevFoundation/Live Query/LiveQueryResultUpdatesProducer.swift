//
//  LiveQueryResultUpdatesProducer.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 11/24/2026.
//

import Foundation

/// A type that produces a sequence of result updates for query fragments.
///
/// Conform to this protocol when a query fragment’s results can change after they’re first produced, like a search
/// over local data that should update when the data does. ``LiveQuery`` iterates the sequence for the latest query
/// fragment and updates its results each time the sequence produces a value. When the query fragment changes, the live
/// query cancels its iteration of the previous fragment’s sequence.
///
/// For example, a producer can return a database observation that produces the current search results, then new
/// results each time the database changes:
///
///     struct NoteSearchProducer: LiveQueryResultUpdatesProducer {
///         let noteStore: NoteStore
///
///         var schedulingStrategy: LiveQuerySchedulingStrategy {
///             .passthrough
///         }
///
///         func resultUpdates(
///             forQueryFragment queryFragment: String
///         ) -> some AsyncSequence<[Note], any Error> & Sendable {
///             noteStore.observeNotes(matching: queryFragment)
///         }
///     }
///
///     let liveQuery = LiveQuery(resultUpdatesProducer: NoteSearchProducer(noteStore: noteStore))
///
/// If results don’t change after they’re produced, conform to ``LiveQueryResultsProducer`` instead. It refines this
/// protocol, providing a default implementation of ``resultUpdates(forQueryFragment:)`` that produces results once.
public protocol LiveQueryResultUpdatesProducer<Results>: Sendable {
    /// The type of results that instances produce.
    associatedtype Results: Sendable

    /// The type of sequence that instances return for each query fragment.
    associatedtype ResultUpdates: AsyncSequence<Results, any Error> & Sendable

    /// The strategy used to schedule result production.
    var schedulingStrategy: LiveQuerySchedulingStrategy { get }

    /// Returns a canonical form of the query fragment, or `nil` if it’s invalid.
    ///
    /// Conforming types can use this function to sanitize or validate query fragments before producing results. The
    /// default implementation trims whitespace, collapses multiple spaces into one, and returns `nil` for empty
    /// strings.
    ///
    /// When this function returns `nil`, live queries don’t produce results for the query fragment. They keep their
    /// results, and keep iterating the previous query fragment’s result updates if they haven’t finished.
    ///
    /// - Parameter queryFragment: The query fragment to canonicalize.
    func canonicalQueryFragment(from queryFragment: String) -> String?

    /// Returns a sequence of results for the specified query fragment.
    ///
    /// The sequence should produce the query fragment’s current results first, followed by new results each time they
    /// change. Live queries cancel their iteration of the sequence when the query fragment changes, so the sequence
    /// should stop producing values when it’s cancelled.
    ///
    /// - Parameter queryFragment: A canonical query fragment. Live queries ensure this is already canonicalized before
    ///   calling this function.
    func resultUpdates(forQueryFragment queryFragment: String) -> ResultUpdates
}


extension LiveQueryResultUpdatesProducer {
    public func canonicalQueryFragment(from queryFragment: String) -> String? {
        let canonicalFragment = queryFragment.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        return canonicalFragment.isEmpty ? nil : canonicalFragment
    }
}
