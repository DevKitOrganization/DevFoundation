//
//  Date+IsApproximatelyEqual.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 6/16/25.
//

import Foundation
import RealModule

extension Date {
    func isApproximatelyEqual(to date: Date, absoluteTolerance: TimeInterval) -> Bool {
        return timeIntervalSinceReferenceDate.isApproximatelyEqual(
            to: date.timeIntervalSinceReferenceDate,
            absoluteTolerance: absoluteTolerance
        )
    }
}
