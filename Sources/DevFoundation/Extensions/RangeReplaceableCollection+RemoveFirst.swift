//
//  RangeReplaceableCollection+RemoveFirst.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 4/4/25.
//

import Foundation


extension RangeReplaceableCollection {
    /// Removes the first element in the collection that satisfies the given predicate.
    ///
    /// - Parameter shouldBeRemoved: A closure that takes an element of the collection as its argument and returns a
    ///   Boolean value indicating whether the element should be removed from the collection.
    /// - Returns: The element that was removed, or `nil` if no elements satisfied the predicate.
    @discardableResult
    mutating func removeFirst(where shouldBeRemoved: (Element) throws -> Bool) rethrows -> Element? {
        return try firstIndex(where: shouldBeRemoved).map { remove(at: $0) }
    }
}
