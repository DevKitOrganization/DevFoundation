//
//  URLPathComponentTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/18/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct URLPathComponentTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initRemovesSlashCharacters() {
        let nonSlashComponents = Array(count: 5) { randomAlphanumericString() }
        let inputRawValue = nonSlashComponents.joined(separator: "/")
        let expectedRawValue = nonSlashComponents.joined()

        let unlabeledInitComponent = URLPathComponent(inputRawValue)
        #expect(unlabeledInitComponent.rawValue == expectedRawValue)

        let labeledInitComponent = URLPathComponent(rawValue: inputRawValue)
        #expect(labeledInitComponent.rawValue == expectedRawValue)

        let componentFromStringLiteral: URLPathComponent = "/spacely/sprockets"
        #expect(componentFromStringLiteral.rawValue == "spacelysprockets")
    }
}
