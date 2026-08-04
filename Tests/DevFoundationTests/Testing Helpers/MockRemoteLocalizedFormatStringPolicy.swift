//
//  MockRemoteLocalizedFormatStringPolicy.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/4/26.
//

import DevFoundation
import DevTesting
import Foundation

final class MockRemoteLocalizedFormatStringPolicy: RemoteLocalizedFormatStringPolicy {
    struct AllowsRemoteFormatStringArguments {
        let remoteFormatString: String
        let localFormatString: String
        let key: String
    }


    nonisolated(unsafe) var allowsRemoteFormatStringStub: Stub<AllowsRemoteFormatStringArguments, Bool>!


    func allowsRemoteFormatString(
        _ remoteFormatString: String,
        localFormatString: String,
        key: String,
    ) -> Bool {
        allowsRemoteFormatStringStub(
            .init(
                remoteFormatString: remoteFormatString,
                localFormatString: localFormatString,
                key: key,
            )
        )
    }
}
