//
//  LiveQuerySchedulingStrategy.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 10/23/2025.
//

import Foundation

/// A strategy for scheduling when result production occurs as query fragments change.
///
/// Different strategies balance user experience against resource usage. Some strategies prioritize showing results
/// immediately, while others wait to reduce unnecessary queries. Live queries automatically skip duplicate query
/// fragments to prevent redundant work.
public struct LiveQuerySchedulingStrategy: Hashable, Sendable {
    /// The underlying strategies used to schedule result production.
    ///
    /// This enum exists so that we can add new strategies without breaking the public API.
    enum Strategy: Hashable, Sendable {
        /// Produces results for every change immediately.
        case passthrough

        /// Waits for changes to stop before producing results.
        case debounce(Duration)
    }


    /// The strategy used to schedule result production.
    let strategy: Strategy


    /// Produces results immediately for every query fragment change.
    ///
    /// Use this strategy when results are cheap to produce, like filtering in-memory data or validating input.
    public static let passthrough = Self(strategy: .passthrough)


    /// Waits for typing to pause before producing results.
    ///
    /// Debouncing delays result production until the query fragment hasn’t changed for the specified duration. This
    /// minimizes the number of queries at the cost of slightly delayed feedback. If a user types “search” rapidly,
    /// results only appear after they stop typing.
    ///
    /// This strategy is best for expensive operations like API calls where reducing request volume matters more than
    /// instant feedback. Keep durations under 500ms to avoid feeling sluggish. Typical ranges are between 250–500ms.
    ///
    /// - Parameter duration: How long to wait after the last change before producing results.
    public static func debounce(_ duration: Duration) -> Self {
        Self(strategy: .debounce(duration))
    }
}
