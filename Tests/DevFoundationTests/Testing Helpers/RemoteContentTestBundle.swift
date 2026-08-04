//
//  RemoteContentTestBundle.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/4/26.
//

import DevTesting
import Foundation
import Testing

extension RandomValueGenerating {
    /// Creates a temporary bundle on disk containing the specified localized strings.
    mutating func createTestBundle(with localizedStrings: [String: String]) throws -> Bundle {
        let tempDirectory = FileManager.default.temporaryDirectory
        let bundleURL = tempDirectory.appendingPathComponent("\(randomAlphanumericString(count: 32)).bundle")
        let resourcesURL = bundleURL.appendingPathComponent("Contents/Resources")

        try FileManager.default.createDirectory(at: resourcesURL, withIntermediateDirectories: true)

        let localizedStringsData = try PropertyListEncoder().encode(localizedStrings)
        try localizedStringsData.write(to: resourcesURL.appendingPathComponent("Localizable.strings"))

        return try #require(Bundle(url: bundleURL))
    }
}
