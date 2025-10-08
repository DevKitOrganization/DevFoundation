//
//  Duration+TimeInterval.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 10/8/25.
//

import Foundation

extension Duration {
    /// A `TimeInterval` representation of the duration.
    ///
    /// This computed property converts the duration to a `TimeInterval` by dividing the duration by one second. This is
    /// useful for interoperability with APIs that expect `TimeInterval` values, such as Foundation’s `Date` APIs.
    public var timeInterval: TimeInterval {
        TimeInterval(self / .seconds(1.0))
    }
}
