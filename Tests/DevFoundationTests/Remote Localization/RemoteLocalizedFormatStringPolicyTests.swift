//
//  RemoteLocalizedFormatStringPolicyTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/4/26.
//

import DevTesting
import Foundation
import Testing

@testable import DevFoundation

struct RemoteLocalizedFormatStringPolicyTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    @DefaultRemoteContentBundleActor
    func currentDefaultsToDisallowedPolicy() {
        #expect(RemoteLocalizedFormatStringPolicies.current is DisallowedRemoteLocalizedFormatStringPolicy)
    }


    @Test
    @DefaultRemoteContentBundleActor
    func currentRoundTrips() {
        defer { RemoteLocalizedFormatStringPolicies.current = RemoteLocalizedFormatStringPolicies.disallowed }

        let mockPolicy = MockRemoteLocalizedFormatStringPolicy()
        RemoteLocalizedFormatStringPolicies.current = mockPolicy

        #expect((RemoteLocalizedFormatStringPolicies.current as? MockRemoteLocalizedFormatStringPolicy) === mockPolicy)
    }


    @Test
    mutating func disallowedPolicyReturnsFalseForRandomKeysAndValues() {
        let isAllowed = RemoteLocalizedFormatStringPolicies.disallowed.allowsRemoteFormatString(
            randomAlphanumericString(),
            localFormatString: randomAlphanumericString(),
            key: randomAlphanumericString(),
        )

        #expect(!isAllowed)
    }
}
