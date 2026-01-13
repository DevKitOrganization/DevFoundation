//
//  Bundle+RemoteContent.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 1/13/26.
//

import Foundation
import Synchronization

extension Bundle {
    /// A mutex used to synchronize access to the default remote content bundle.
    private static let defaultRemoteContentBundleMutex: Mutex<Bundle?> = .init(nil)


    /// The default bundle used to load remote content, such as localized strings fetched from a server.
    ///
    /// This property is thread-safe and can be accessed from multiple threads concurrently.
    ///
    /// Set this property after creating a remote content bundle using
    /// ``makeRemoteContentBundle(at:localizedStrings:)``. Once set, you can use this bundle to look up localized
    /// strings that were downloaded from a remote source.
    ///
    /// - Note: This property is `nil` by default and must be explicitly set before use.
    public static var defaultRemoteContentBundle: Bundle? {
        get {
            defaultRemoteContentBundleMutex.withLock(\.self)
        }

        set {
            defaultRemoteContentBundleMutex.withLock { $0 = newValue }
        }
    }


    /// Creates and returns a remote content bundle at the specified URL.
    ///
    /// - Parameters:
    ///   - bundleURL: The URL at which to create the remote content bundle.
    ///   - localizedStrings: The localized strings to store in the bundle.
    public static func makeRemoteContentBundle(
        at bundleURL: URL,
        localizedStrings: [String: String]
    ) throws -> Bundle? {
        // We write directly into the resources directory rather than putting it in an lproj, as we don’t actually
        // know language the strings are in.
        let resourcesDirectoryURL = bundleURL.appending(path: "Contents/Resources")
        try FileManager.default.createDirectory(at: resourcesDirectoryURL, withIntermediateDirectories: true)

        let localizedStringsData = try PropertyListEncoder().encode(localizedStrings)
        try localizedStringsData.write(to: resourcesDirectoryURL.appendingPathComponent("Localizable.strings"))

        return Bundle(url: bundleURL)
    }
}
