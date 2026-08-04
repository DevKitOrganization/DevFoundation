//
//  RemoteLocalizedFormatStringPolicy.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/4/26.
//

import Foundation
import Synchronization
import os

/// DevFoundation’s logger for outputting information about remote localized format string policies.
let remoteLocalizedFormatStringPoliciesLogger = Logger(
    subsystem: "DevFoundation",
    category: "remoteLocalizedFormatStringPolicies",
)


/// A type that decides whether format strings from remote content may be used.
///
/// Remote localization resolves plain strings from content fetched at runtime, falling back to the app’s compiled
/// catalog when the remote content has no entry for a key. This is safe for plain strings, but can result in incorrect
/// or insecure behavior when used with _format_ strings. For example, if a format string has more conversion specifiers
/// than passed-in parameters, the process can crash or adjacent stack memory can be output to the string.
///
/// By default, DevFoundation never uses remote format strings; see ``RemoteLocalizedFormatStringPolicies/current``,
/// which defaults to ``RemoteLocalizedFormatStringPolicies/disallowed``. A conforming policy is how an app opts back
/// in for keys it has decided are safe.
///
///
/// ## Writing a Policy
///
/// ``allowsRemoteFormatString(_:localFormatString:key:)`` receives both format strings already resolved, so a
/// policy can compare them. At minimum, a policy that isn’t simply `true` or `false` for every key should check that
/// the remote string has the same number and types of conversions as the local one:
///
///     struct SpecifierCountPolicy: RemoteLocalizedFormatStringPolicy {
///         func allowsRemoteFormatString(
///             _ remoteFormatString: String,
///             localFormatString: String,
///             key: String,
///         ) -> Bool {
///             return conversions(in: remoteFormatString) == conversions(in: localFormatString)
///         }
///
///         private func conversions(in formatString: String) -> [Character] {
///             // Parse `formatString` and return its conversions, e.g., ["@", "d"] for "%@ has %d lives".
///         }
///     }
///
///
/// ## Logging Refusals
///
/// A policy is also the natural place to log or emit telemetry when a remote format string is refused:
///
///     struct LoggingPolicy: RemoteLocalizedFormatStringPolicy {
///         func allowsRemoteFormatString(
///             _ remoteFormatString: String,
///             localFormatString: String,
///             key: String,
///         ) -> Bool {
///             let isAllowed = // ...
///             if !isAllowed {
///                 logger.warning("Refused remote format string for key \(key)")
///             }
///             return isAllowed
///         }
///     }
public protocol RemoteLocalizedFormatStringPolicy: Sendable {
    /// Returns whether a remote format string may be used in place of the local one.
    ///
    /// Because format strings may be used in user-facing code, take care to ensure this function is as fast as
    /// possible.
    ///
    /// - Parameters:
    ///   - remoteFormatString: The format string from the remote content bundle.
    ///   - localFormatString: The format string from the app’s local bundle.
    ///   - key: The localization key for which both strings are values.
    func allowsRemoteFormatString(
        _ remoteFormatString: String,
        localFormatString: String,
        key: String,
    ) -> Bool
}


/// A namespace for accessing remote localized format string policies.
public enum RemoteLocalizedFormatStringPolicies {
    /// A mutex that synchronizes access to the current policy.
    private static let currentPolicy: Mutex<any RemoteLocalizedFormatStringPolicy> = .init(
        DisallowedRemoteLocalizedFormatStringPolicy()
    )


    /// The current remote localized format string policy.
    ///
    /// Defaults to ``disallowed``.
    public static var current: any RemoteLocalizedFormatStringPolicy {
        get {
            return currentPolicy.withLock { $0 }
        }
        set {
            remoteLocalizedFormatStringPoliciesLogger.info(
                "Setting current remote localized format string policy to \(String(describing: newValue))"
            )
            currentPolicy.withLock { $0 = newValue }
        }
    }


    /// A policy that never allows remote format strings.
    public static var disallowed: some RemoteLocalizedFormatStringPolicy {
        return DisallowedRemoteLocalizedFormatStringPolicy()
    }
}


/// A policy that never allows remote format strings.
struct DisallowedRemoteLocalizedFormatStringPolicy: RemoteLocalizedFormatStringPolicy {
    /// Always returns `false`.
    func allowsRemoteFormatString(
        _ remoteFormatString: String,
        localFormatString: String,
        key: String,
    ) -> Bool {
        return false
    }
}
