//
//  MockRandomAccessPageLoader.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/9/25.
//

import DevFoundation
import DevTesting
import Foundation

final class MockRandomAccessPageLoader<Page>: RandomAccessPageLoader where Page: OffsetPage {
    nonisolated(unsafe) var pageExistsStub: Stub<Int, Bool>!
    nonisolated(unsafe) var loadPagePrologue: (() async throws -> Void)?
    nonisolated(unsafe) var loadPageStub: ThrowingStub<Int, Page, any Error>!


    func pageExists(at offset: Int) -> Bool {
        pageExistsStub(offset)
    }


    func loadPage(at offset: Int) async throws -> Page {
        try await loadPagePrologue?()
        return try loadPageStub(offset)
    }
}
