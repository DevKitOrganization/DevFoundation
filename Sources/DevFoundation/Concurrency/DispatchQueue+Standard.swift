//
//  DispatchQueue+Standard.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 4/1/25.
//

import Foundation

extension DispatchQueue {
    /// A non-overcommitting, serial dispatch queue that can be used to execute utility tasks.
    ///
    /// While you can use this queue directly, it is better to create your own queue that uses this one as a target. The
    /// queue uses `.utility` for its quality-of-service.
    public static let utility: DispatchQueue = .makeNonOvercommitting(
        label: reverseDNSPrefixed("utility"),
        qos: .utility
    )
}
