//
//  OffsetDateProvider.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 6/16/25.
//

import Foundation

/// A date provider that returns a date that is offset from a base provider’s by some fixed time interval.
struct OffsetDateProvider<Base>: DateProvider where Base: DateProvider {
    /// The base date provider whose dates this provider’s dates are relative to.
    private let base: Base

    /// The time interval that this provider adds to the base provider’s dates.
    private let offset: TimeInterval


    /// Creates a new `OffsetDateProvider` with the specified base and offset.
    ///
    /// - Parameters:
    ///   - base: The base date provider whose dates this provider’s dates are relative to.
    ///   - offset: The time interval that the new date provider adds to its base provider’s dates.
    init(base: Base, offset: TimeInterval) {
        self.base = base
        self.offset = offset
    }


    var now: Date {
        return base.now + offset
    }
}


extension OffsetDateProvider: CustomStringConvertible {
    public var description: String {
        return "\(base).offset(by: \(offset))"
    }
}


extension DateProvider {
    /// Returns a relative date provider whose current date is offset from this one’s by a constant time interval.
    ///
    /// - Parameter offset: The time interval to add to this date provider’s dates.
    public func offset(by offset: TimeInterval) -> some DateProvider {
        return OffsetDateProvider(base: self, offset: offset)
    }
}
