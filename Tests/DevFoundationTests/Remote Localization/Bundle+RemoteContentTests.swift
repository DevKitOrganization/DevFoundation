//
//  Bundle+RemoteContentTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 1/13/26.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct Bundle_RemoteContentTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func createsValidBundleWithLocalizedStrings() throws {
        // set up the test by creating a bundle URL and localized strings
        let bundleURL = makeTestBundleURL()
        let localizedStrings = Dictionary(count: randomInt(in: 3 ..< 10)) {
            (randomAlphanumericString(), randomAlphanumericString())
        }

        // exercise the test by creating the remote content bundle
        let bundle = try #require(try Bundle.makeRemoteContentBundle(at: bundleURL, localizedStrings: localizedStrings))

        // expect that the bundle was created at the correct URL with the correct structure
        #expect(bundle.bundleURL.standardizedFileURL == bundleURL.standardizedFileURL)
        let stringsFileURL = bundleURL.appending(path: "Contents/Resources/Localizable.strings")
        #expect(FileManager.default.fileExists(atPath: stringsFileURL.path))
        #expect(Bundle(url: bundleURL) != nil)

        // expect that the bundle can look up the localized strings
        for (key, value) in localizedStrings {
            #expect(bundle.localizedString(forKey: key, value: nil, table: nil) == value)
        }
    }


    @Test
    mutating func createsValidBundleWithEmptyLocalizedStrings() throws {
        // set up the test by creating a bundle URL
        let bundleURL = makeTestBundleURL()

        // exercise the test by creating the remote content bundle with an empty dictionary
        let bundle = try #require(try Bundle.makeRemoteContentBundle(at: bundleURL, localizedStrings: [:]))

        // expect that the bundle was created at the correct URL with the correct structure
        #expect(bundle.bundleURL.standardizedFileURL == bundleURL.standardizedFileURL)
        let stringsFileURL = bundleURL.appending(path: "Contents/Resources/Localizable.strings")
        #expect(FileManager.default.fileExists(atPath: stringsFileURL.path))
        #expect(Bundle(url: bundleURL) != nil)
    }


    @Test
    @DefaultRemoteContentBundleActor
    mutating func defaultRemoteContentBundleGetAndSet() throws {
        // set up the test by ensuring the bundle is nil and creating a test bundle
        #expect(Bundle.defaultRemoteContentBundle == nil)
        defer { Bundle.defaultRemoteContentBundle = nil }

        let bundleURL = makeTestBundleURL()
        let bundle = try #require(try Bundle.makeRemoteContentBundle(at: bundleURL, localizedStrings: [:]))

        // exercise the test by setting the default remote content bundle
        Bundle.defaultRemoteContentBundle = bundle

        // expect that the bundle can be retrieved
        #expect(Bundle.defaultRemoteContentBundle === bundle)
    }


    private mutating func makeTestBundleURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(randomAlphanumericString(count: 32))
            .appendingPathComponent("RemoteContent.bundle")
    }
}
