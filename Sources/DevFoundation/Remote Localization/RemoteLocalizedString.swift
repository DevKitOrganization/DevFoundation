//
//  RemoteLocalizedString.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 1/13/26.
//

import Foundation

/// Returns a localized version of the key using a combination of remote- and local localization data.
///
/// The function works by first checking the remote content bundle, and if no key is found, falling back to the local
/// bundle.
///
/// You should generally use the ``#remoteLocalizedString(_:bundle:)`` macro instead of using this function directly.
///
/// - Warning: Do not use the returned string as a format string, e.g., with `String(format:)`. Remote content here
///   is not vetted for that use. Use ``remoteLocalizedFormatString(_:key:bundle:remoteContentBundle:policy:)`` for
///   format strings instead.
///
/// - Parameters:
///   - keyAndValue: A `String.LocalizationValue` that provides the localization key to look up. This parameter also
///     serves as the default value if the system can’t find a localized string.
///   - key: A string representation of the localization key.
///   - bundle: The bundle to use for looking up strings if a string cannot be found in the remote content bundle.
///   - remoteContentBundle: The bundle to use to look up remote localization data. If `nil`, no remote content is used.
///     Defaults to ``Foundation/Bundle/defaultRemoteContentBundle``.
public func remoteLocalizedString(
    _ keyAndValue: String.LocalizationValue,
    key: String,
    bundle: Bundle,
    remoteContentBundle: Bundle? = .defaultRemoteContentBundle,
) -> String {
    if let remoteContentBundle {
        let value = String(localized: keyAndValue, bundle: remoteContentBundle)

        // If you got back a value that was different than the key, that suggests that it was localized, so return it
        if value != key {
            return value
        }
    }

    return String(localized: keyAndValue, bundle: bundle)
}


/// A macro that returns a localized version of the key using a combination of remote- and local localization data.
///
/// This macro transforms:
///
///     #remoteLocalizedString("feline.adoptionMessage")
///
/// Into:
///
///     remoteLocalizedString(
///         "feline.adoptionMessage",
///         key: "feline.adoptionMessage",
///         bundle: #bundle
///     )
///
/// - Warning: Do not use the returned string as a format string, e.g., with `String(format:)`. Remote content here
///   is not vetted for that use. Use ``#remoteLocalizedString(format:bundle:_:)`` for format strings instead.
///
/// - Parameters:
///   - key: A string literal containing the localization key.
///   - bundle: The bundle to use for looking up strings if a string cannot be found in the remote content bundle.
///     `#bundle` by default.
@freestanding(expression)
public macro remoteLocalizedString(_ key: String, bundle: Bundle = #bundle) -> String =
    #externalMacro(module: "RemoteLocalizationMacros", type: "RemoteLocalizedStringMacro")


/// Returns a formatted, localized version of the key using a combination of remote- and local localization data.
///
/// You should generally use the ``#remoteLocalizedString(format:bundle:_:)`` macro instead of using this function
/// directly.
///
/// - Warning: The returned string is only ever a remote value if `policy` allows it. The default policy,
///   ``RemoteLocalizedFormatStringPolicies/disallowed``, never does.
///
/// - Parameters:
///   - keyAndValue: A `String.LocalizationValue` that provides the localization key to look up. This parameter also
///     serves as the default value if the system can’t find a localized string.
///   - key: A string representation of the localization key.
///   - bundle: The bundle to use for looking up the local format string.
///   - remoteContentBundle: The bundle to use to look up a remote format string. If `nil`, no remote content is used.
///     Defaults to ``Foundation/Bundle/defaultRemoteContentBundle``.
///   - policy: The policy that decides whether the remote format string may be used. Defaults to
///     ``RemoteLocalizedFormatStringPolicies/current``.
public func remoteLocalizedFormatString(
    _ keyAndValue: String.LocalizationValue,
    key: String,
    bundle: Bundle,
    remoteContentBundle: Bundle? = .defaultRemoteContentBundle,
    policy: any RemoteLocalizedFormatStringPolicy = RemoteLocalizedFormatStringPolicies.current,
) -> String {
    let localFormatString = String(localized: keyAndValue, bundle: bundle)

    guard let remoteContentBundle else {
        return localFormatString
    }

    let remoteFormatString = String(localized: keyAndValue, bundle: remoteContentBundle)

    // Getting the key back means the remote bundle has no entry for it
    guard remoteFormatString != key else {
        return localFormatString
    }

    guard
        policy.allowsRemoteFormatString(
            remoteFormatString,
            localFormatString: localFormatString,
            key: key,
        )
    else {
        return localFormatString
    }

    return remoteFormatString
}


/// A macro that returns a formatted localized string using a combination of remote- and local localization data.
///
/// This macro transforms:
///
///     #remoteLocalizedString(format: "feline.count.format", bundle: .main, catCount, kittenCount)
///
/// Into:
///
///     String.localizedStringWithFormat(
///         remoteLocalizedFormatString("feline.count.format", key: "feline.count.format", bundle: .main),
///         catCount, kittenCount
///     )
///
/// - Warning: A remote format string is only used if a ``RemoteLocalizedFormatStringPolicy`` allows it. By default,
///   none does. See ``RemoteLocalizedFormatStringPolicies``.
///
/// - Parameters:
///   - format: A string literal containing the localization key for the format string.
///   - bundle: The bundle to use for looking up strings if a string cannot be found in the remote content bundle.
///     `#bundle` by default.
///   - arguments: The arguments to substitute into the format string.
@freestanding(expression)
public macro remoteLocalizedString(format: String, bundle: Bundle = #bundle, _ arguments: any CVarArg...) -> String =
    #externalMacro(module: "RemoteLocalizationMacros", type: "RemoteLocalizedStringWithFormatMacro")
