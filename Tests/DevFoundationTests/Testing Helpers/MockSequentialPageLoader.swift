//
//  MockSequentialPageLoader.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/9/25.
//

import DevFoundation
import DevTesting
import Foundation

final class MockSequentialPageLoader<Page>: SequentialPageLoader where Page: OffsetPage {
    nonisolated(unsafe) var pageExistsStub: Stub<Page, Bool>!
    nonisolated(unsafe) var loadPagePrologue: (() async throws -> Void)?
    nonisolated(unsafe) var loadPageStub: ThrowingStub<Page?, Page, any Error>!


    func pageExists(after page: Page) -> Bool {
        pageExistsStub(page)
    }


    func loadPage(after page: Page?) async throws -> Page {
        try await loadPagePrologue?()
        return try loadPageStub(page)
    }
}
