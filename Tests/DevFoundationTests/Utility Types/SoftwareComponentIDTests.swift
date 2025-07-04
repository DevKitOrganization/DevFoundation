//
//  SoftwareComponentIDTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/13/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct SoftwareComponentIDTests {
    @Test
    func initOmitsEmptyComponents() {
        let id = SoftwareComponentID(".....a....b.c...d..e.f...")
        #expect(id.rawValue == "a.b.c.d.e.f")
    }
}
