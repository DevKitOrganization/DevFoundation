//
//  MockOffsetPage.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/9/25.
//

import DevFoundation
import DevTesting
import Foundation

final class MockOffsetPage: OffsetPage, HashableByID {
    nonisolated(unsafe) var pageOffsetStub: Stub<Void, Int>!


    var pageOffset: Int {
        pageOffsetStub()
    }
}
