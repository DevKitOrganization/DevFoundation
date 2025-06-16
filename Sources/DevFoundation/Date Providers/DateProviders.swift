//
//  DateProviders.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 6/16/25.
//

import Foundation
import Synchronization
import os


/// DevFoundation’s logger for outputting information about date providers.
let dateProvidersLogger = Logger(subsystem: "DevFoundation", category: "dateProviders")


/// A namespace for accessing date providers.
public enum DateProviders {
    /// A mutex that synchronizes access to the current date provider.
    private static let currentDateProvider: Mutex<any DateProvider> = .init(SystemDateProvider())

    
    /// The current date provider.
    ///
    /// - Warning: Setting this value to a date provider that references the auto-updating current date provider, e.g.,
    ///   by scaling or offsetting it, will cause an infinite loop when getting the date.
    public static var current: any DateProvider {
        get {
            return currentDateProvider.withLock { $0 }
        }
        set {
            dateProvidersLogger.info("Setting current date provider to \(String(describing: newValue))")
            currentDateProvider.withLock { $0 = newValue }
        }
    }


    /// A date provider that tracks the current one.
    public static var autoupdatingCurrent: some DateProvider {
        return AutoupdatingCurrentDateProvider()
    }


    /// A date provider that returns the current system date.
    public static var system: some DateProvider {
        return SystemDateProvider()
    }
}


/// A date provider that tracks the current date provider.
struct AutoupdatingCurrentDateProvider: DateProvider {
    /// Returns the current date provider’s current date.
    var now: Date {
        DateProviders.current.now
    }
}
