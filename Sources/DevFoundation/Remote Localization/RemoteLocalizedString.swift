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
    remoteContentBundle: Bundle? = .defaultRemoteContentBundle
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
///     localizedString(
///         "feline.adoptionMessage",
///         key: "feline.adoptionMessage",
///         bundle: #bundle
///     )
///
/// - Parameters:
///   - key: A string literal containing the localization key.
///   - bundle: The bundle to use for looking up strings if a string cannot be found in the remote content bundle.
///     `#bundle` by default.
@freestanding(expression)
public macro remoteLocalizedString(_ key: String, bundle: Bundle = #bundle) -> String =
    #externalMacro(module: "RemoteLocalizationMacros", type: "RemoteLocalizedStringMacro")


/// A macro that returns a formatted localized string using a combination of remote- and local localization data.
///
/// This macro transforms:
///
///     #remoteLocalizedString(format: "feline.count.format", bundle: .main, catCount, kittenCount)
///
/// Into:
///
///     String.localizedStringWithFormat(
///         #remoteLocalizedString("feline.count.format", bundle: .main),
///         catCount, kittenCount
///     )
///
/// - Parameters:
///   - format: A string literal containing the localization key for the format string.
///   - bundle: The bundle to use for looking up strings if a string cannot be found in the remote content bundle.
///     `#bundle` by default.
///   - arguments: The arguments to substitute into the format string.
@freestanding(expression)
public macro remoteLocalizedString(format: String, bundle: Bundle = #bundle, _ arguments: any CVarArg...) -> String =
    #externalMacro(module: "RemoteLocalizationMacros", type: "RemoteLocalizedStringWithFormatMacro")
