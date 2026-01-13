//
//  LocalizationTests.swift
//  AppPlatform
//
//  Created by Prachi Gauriar on 9/19/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

@DefaultRemoteContentBundleActor
struct LocalizationTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func localizedStringReturnsValueFromRemoteBundleWhenKeyExists() throws {
        defer { Bundle.defaultRemoteContentBundle = nil }

        let key = randomAlphanumericString()
        let remoteValue = randomAlphanumericString()
        let localValue = randomAlphanumericString()

        let remoteBundle = try createTestBundle(with: [key: remoteValue])
        Bundle.defaultRemoteContentBundle = remoteBundle

        let localBundle = try createTestBundle(with: [key: localValue])
        let result = remoteLocalizedString(String.LocalizationValue(key), key: key, bundle: localBundle)
        #expect(result == remoteValue)
    }


    @Test
    mutating func localizedStringFallsBackToLocalBundleWhenKeyNotInRemote() throws {
        let remoteKey = randomAlphanumericString()
        let localKey = randomAlphanumericString()
        let remoteValue = randomAlphanumericString()
        let localValue = randomAlphanumericString()

        let remoteBundle = try createTestBundle(with: [remoteKey: remoteValue])
        let localBundle = try createTestBundle(with: [localKey: localValue])

        let result = remoteLocalizedString(
            String.LocalizationValue(localKey),
            key: localKey,
            bundle: localBundle,
            remoteContentBundle: remoteBundle
        )

        #expect(result == localValue)
    }


    @Test
    mutating func localizedStringUsesLocalBundleWhenNoRemoteBundle() throws {
        Bundle.defaultRemoteContentBundle = nil

        let key = randomAlphanumericString()
        let localValue = randomAlphanumericString()

        let localBundle = try createTestBundle(with: [key: localValue])

        let result = remoteLocalizedString(String.LocalizationValue(key), key: key, bundle: localBundle)

        #expect(result == localValue)
    }


    private mutating func createTestBundle(with localizedStrings: [String: String]) throws -> Bundle {
        let tempDirectory = FileManager.default.temporaryDirectory
        let bundleURL = tempDirectory.appendingPathComponent("\(randomAlphanumericString(count: 32)).bundle")
        let resourcesURL = bundleURL.appendingPathComponent("Contents/Resources")

        try FileManager.default.createDirectory(at: resourcesURL, withIntermediateDirectories: true)

        let localizedStringsData = try PropertyListEncoder().encode(localizedStrings)
        try localizedStringsData.write(to: resourcesURL.appendingPathComponent("Localizable.strings"))

        return try #require(Bundle(url: bundleURL))
    }
}
