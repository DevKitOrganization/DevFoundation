//
//  DateProvider.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 6/16/25.
//

import Foundation

/// A type that provides the current date.
///
/// Date providers make it easier to test code that relies on dates. Tests can mock date providers to always return
/// a static value or run fast or slow.
///
/// To make effective use of `DateProvider`, you should never use Foundation APIs that implicitly use the current date,
/// e.g., `Date()` or `Date(timeIntervalSinceNow:)`. Instead, use a ``now`` with APIs that take a reference date, like
/// `Date(timeInterval:since:)`.
public protocol DateProvider: Sendable {
    /// The current date, according to the date provider.
    var now: Date { get }
}
