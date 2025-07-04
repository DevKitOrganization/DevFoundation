//
//  SystemDateProvider.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 6/16/25.
//

import Foundation

/// A date provider whose dates match the current system date.
struct SystemDateProvider: DateProvider {
    var now: Date {
        return Date()
    }
}


extension SystemDateProvider: CustomStringConvertible {
    public var description: String {
        return "DateProviders.system"
    }
}
