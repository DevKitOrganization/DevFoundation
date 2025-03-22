//
//  UnauthorizedHTTPRequestErrorTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/16/25.
//

import DevFoundation
import Foundation
import Testing


struct UnauthorizedHTTPRequestErrorTests {
    @Test
    func initDoesNothing() {
        let error = UnauthorizedHTTPRequestError() as any Error
        #expect(error is UnauthorizedHTTPRequestError)
    }
}
