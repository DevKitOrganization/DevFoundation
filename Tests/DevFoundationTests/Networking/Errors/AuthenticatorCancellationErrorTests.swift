//
//  AuthenticatorCancellationErrorTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/18/25.
//

import DevFoundation
import Foundation
import Testing

struct AuthenticatorCancellationErrorTests {
    @Test
    func initDoesNothing() {
        let error = AuthenticatorCancellationError() as any Error
        #expect(error is AuthenticatorCancellationError)
    }
}
