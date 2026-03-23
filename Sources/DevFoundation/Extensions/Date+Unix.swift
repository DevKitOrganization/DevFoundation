//
//  Date+Unix.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/23/26.
//

import Foundation

extension Date {
    /// Creates a date from the given number of whole seconds since January 1, 1970 at 00:00:00 UTC.
    ///
    /// - Parameter secondsSince1970: The number of whole seconds since the Unix epoch.
    public init(secondsSince1970: Int64) {
        self.init(timeIntervalSince1970: TimeInterval(secondsSince1970))
    }


    /// Creates a date from the given number of whole milliseconds since January 1, 1970 at 00:00:00 UTC.
    ///
    /// - Parameter millisecondsSince1970: The number of whole milliseconds since the Unix epoch.
    public init(millisecondsSince1970: Int64) {
        self.init(millisecondsSince1970: Float64(millisecondsSince1970))
    }


    /// Creates a date from the given number of fractional milliseconds since January 1, 1970 at 00:00:00 UTC.
    ///
    /// - Parameter millisecondsSince1970: The number of milliseconds since the Unix epoch.
    public init(millisecondsSince1970: Float64) {
        self.init(timeIntervalSince1970: millisecondsSince1970 / 1000)
    }


    /// The date represented as whole seconds since January 1, 1970 at 00:00:00 UTC.
    ///
    /// The fractional seconds component of the date's time interval is truncated.
    public var secondsSince1970: Int64 {
        return Int64(timeIntervalSince1970)
    }


    /// The date represented as whole milliseconds since January 1, 1970 at 00:00:00 UTC.
    ///
    /// The sub-millisecond component of the date's time interval is truncated.
    public var millisecondsSince1970: Int64 {
        return Int64(timeIntervalSince1970 * 1000)
    }
}
