//
//  ScaledDateProvider.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 6/16/25.
//

import Foundation

/// A date provider that runs at a different rate relative to a base date provider.
struct ScaledDateProvider<Base>: DateProvider where Base: DateProvider {
    /// The base date provider whose dates this provider’s dates are relative to.
    private let base: Base

    /// The scale at which time elapses on this date provider versus its base.
    ///
    /// For example, when this value is 2, time elapses twice as quickly for this date provider than its base provider.
    ///
    /// This value must be postive.
    private let scale: Float64

    /// The base provider’s date when this provider was initialized.
    private let startDate: Date


    /// Creates a new scaled date provider with the specified base and scale.
    ///
    /// - Parameters:
    ///   - base: The base date provider whose dates this provider’s dates are relative to.
    ///   - scale: The scale at which time elapses on this date provider versus its base. Must be positive.
    init(base: Base, scale: Float64) {
        precondition(scale > 0, "Scale must be positive.")
        self.startDate = base.now
        self.base = base
        self.scale = scale
    }


    var now: Date {
        return startDate + base.now.timeIntervalSince(startDate) * scale
    }
}


extension ScaledDateProvider: CustomStringConvertible {
    public var description: String {
        return "\(base).scalingRate(by: \(scale))"
    }
}


extension DateProvider {
    /// Returns a date provider for which time elapses at a different rate than this one.
    ///
    /// - Parameter scale: The scale at which time elapses on this date provider versus its base. For example, when
    ///   scale is 2, time elapses twice as quickly for the new date provider than its base. Must be positive.
    public func scalingRate(by scale: Float64) -> some DateProvider {
        return ScaledDateProvider(base: self, scale: scale)
    }
}
