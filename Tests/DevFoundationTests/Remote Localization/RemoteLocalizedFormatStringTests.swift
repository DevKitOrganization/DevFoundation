//
//  RemoteLocalizedFormatStringTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/4/26.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct RemoteLocalizedFormatStringTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    @DefaultRemoteContentBundleActor
    mutating func underDefaultPolicyRemoteEntryIsIgnored() throws {
        let key = randomAlphanumericString()
        let localFormat = "%d items"
        let remoteFormat = "%d different items"

        let localBundle = try createTestBundle(with: [key: localFormat])
        let remoteBundle = try createTestBundle(with: [key: remoteFormat])

        let resolvedFormat = remoteLocalizedFormatString(
            String.LocalizationValue(key),
            key: key,
            bundle: localBundle,
            remoteContentBundle: remoteBundle,
        )

        #expect(resolvedFormat == localFormat)

        let count = randomInt(in: 0 ..< 1_000)
        let result = String.localizedStringWithFormat(resolvedFormat, count)
        #expect(result == String.localizedStringWithFormat(localFormat, count))
    }


    @Test
    mutating func policyReceivesResolvedFormatStringsAndKey() throws {
        let key = randomAlphanumericString()
        let localFormat = randomAlphanumericString()
        let remoteFormat = randomAlphanumericString()

        let localBundle = try createTestBundle(with: [key: localFormat])
        let remoteBundle = try createTestBundle(with: [key: remoteFormat])

        let mockPolicy = MockRemoteLocalizedFormatStringPolicy()
        mockPolicy.allowsRemoteFormatStringStub = Stub(defaultReturnValue: false)

        _ = remoteLocalizedFormatString(
            String.LocalizationValue(key),
            key: key,
            bundle: localBundle,
            remoteContentBundle: remoteBundle,
            policy: mockPolicy,
        )

        let callArguments = try #require(mockPolicy.allowsRemoteFormatStringStub.callArguments.first)
        #expect(callArguments.remoteFormatString == remoteFormat)
        #expect(callArguments.localFormatString == localFormat)
        #expect(callArguments.key == key)
    }


    @Test
    mutating func policyAllowingRemoteFormatStringUsesRemoteValue() throws {
        let key = randomAlphanumericString()
        let localFormat = randomAlphanumericString()
        let remoteFormat = randomAlphanumericString()

        let localBundle = try createTestBundle(with: [key: localFormat])
        let remoteBundle = try createTestBundle(with: [key: remoteFormat])

        let mockPolicy = MockRemoteLocalizedFormatStringPolicy()
        mockPolicy.allowsRemoteFormatStringStub = Stub(defaultReturnValue: true)

        let result = remoteLocalizedFormatString(
            String.LocalizationValue(key),
            key: key,
            bundle: localBundle,
            remoteContentBundle: remoteBundle,
            policy: mockPolicy,
        )

        #expect(result == remoteFormat)
    }


    @Test
    mutating func noRemoteContentBundleUsesLocalFormatStringWithoutConsultingPolicy() throws {
        let key = randomAlphanumericString()
        let localFormat = randomAlphanumericString()
        let localBundle = try createTestBundle(with: [key: localFormat])

        let result = remoteLocalizedFormatString(
            String.LocalizationValue(key),
            key: key,
            bundle: localBundle,
            remoteContentBundle: nil,
            policy: MockRemoteLocalizedFormatStringPolicy(),
        )

        #expect(result == localFormat)
    }


    @Test
    mutating func remoteBundleWithNoEntryUsesLocalFormatStringWithoutConsultingPolicy() throws {
        let remoteKey = randomAlphanumericString()
        let localKey = randomAlphanumericString()
        let remoteValue = randomAlphanumericString()
        let localFormat = randomAlphanumericString()

        let localBundle = try createTestBundle(with: [localKey: localFormat])
        let remoteBundle = try createTestBundle(with: [remoteKey: remoteValue])

        let result = remoteLocalizedFormatString(
            String.LocalizationValue(localKey),
            key: localKey,
            bundle: localBundle,
            remoteContentBundle: remoteBundle,
            policy: MockRemoteLocalizedFormatStringPolicy(),
        )

        #expect(result == localFormat)
    }


    @Test
    @DefaultRemoteContentBundleActor
    mutating func macroFormResolvesEndToEnd() throws {
        defer { Bundle.defaultRemoteContentBundle = nil }

        let localFormat = "%d of %d"
        let remoteFormat = "%@ %@ %@"

        let testBundle = try createTestBundle(with: ["macroFormatTestKey": localFormat])
        Bundle.defaultRemoteContentBundle = try createTestBundle(with: ["macroFormatTestKey": remoteFormat])

        let result = #remoteLocalizedString(format: "macroFormatTestKey", bundle: testBundle, 1, 5)
        #expect(result == String.localizedStringWithFormat(localFormat, 1, 5))
    }


    @Test
    @DefaultRemoteContentBundleActor
    mutating func vulnerabilityRegressionMismatchedRemoteSpecifiersDoNotCorruptOutput() throws {
        let key = randomAlphanumericString()
        let localFormat = "%d of %d"
        let remoteFormat = "%@ %@ %@"

        let localBundle = try createTestBundle(with: [key: localFormat])
        let remoteBundle = try createTestBundle(with: [key: remoteFormat])

        let resolvedFormat = remoteLocalizedFormatString(
            String.LocalizationValue(key),
            key: key,
            bundle: localBundle,
            remoteContentBundle: remoteBundle,
        )

        #expect(resolvedFormat == localFormat)

        let result = String.localizedStringWithFormat(resolvedFormat, 3, 5)
        #expect(result == String.localizedStringWithFormat(localFormat, 3, 5))
    }
}
