//
//  SequentialPagerTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/9/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct SequentialPagerTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    func initializationSetsUpEmptyPager() {
        let mockLoader = MockSequentialPageLoader<MockOffsetPage>()
        let pager = SequentialPager(pageLoader: mockLoader)

        #expect(pager.loadedPages.isEmpty)
        #expect(pager.lastLoadedPage == nil)
    }


    @Test
    func pageExistsDelegatesToLoader() {
        let mockLoader = MockSequentialPageLoader<MockOffsetPage>()
        mockLoader.pageExistsStub = Stub(defaultReturnValue: true)

        let pager = SequentialPager(pageLoader: mockLoader)
        let page = MockOffsetPage()
        page.pageOffsetStub = Stub(defaultReturnValue: 0)

        #expect(pager.pageExists(after: page))
        #expect(mockLoader.pageExistsStub.callArguments == [page])
    }


    @Test
    func loadPageLoadsFirstPage() async throws {
        let mockLoader = MockSequentialPageLoader<MockOffsetPage>()
        let expectedPage = MockOffsetPage()
        expectedPage.pageOffsetStub = Stub(defaultReturnValue: 0)
        mockLoader.loadPageStub = ThrowingStub(defaultReturnValue: expectedPage)

        let pager = SequentialPager(pageLoader: mockLoader)

        let loadedPage = try await pager.loadPage(after: nil)

        #expect(loadedPage === expectedPage)
        #expect(pager.loadedPages == [expectedPage])
        #expect(pager.lastLoadedPage === expectedPage)
        #expect(mockLoader.loadPageStub.callArguments == [nil])
    }


    @Test
    func loadPageReturnsCachedPage() async throws {
        let mockLoader = MockSequentialPageLoader<MockOffsetPage>()
        let page1 = MockOffsetPage()
        page1.pageOffsetStub = Stub(defaultReturnValue: 0)
        let page2 = MockOffsetPage()
        page2.pageOffsetStub = Stub(defaultReturnValue: 1)

        mockLoader.loadPageStub = ThrowingStub(
            defaultReturnValue: page2,
            resultQueue: [.success(page1)]
        )

        let pager = SequentialPager(pageLoader: mockLoader)

        // Load first two pages
        _ = try await pager.loadPage(after: nil)
        _ = try await pager.loadPage(after: page1)

        // Load first page again - should return cached version
        let cachedPage = try await pager.loadPage(after: nil)

        #expect(cachedPage === page1)
        #expect(pager.loadedPages == [page1, page2])
        #expect(mockLoader.loadPageStub.callArguments == [nil, page1])
    }


    @Test
    mutating func loadPageThrowsError() async {
        let mockLoader = MockSequentialPageLoader<MockOffsetPage>()
        let expectedError = randomError()
        mockLoader.loadPageStub = ThrowingStub(defaultError: expectedError)

        let pager = SequentialPager(pageLoader: mockLoader)

        await #expect(throws: expectedError) {
            try await pager.loadPage(after: nil)
        }

        #expect(pager.loadedPages.isEmpty)
        #expect(pager.lastLoadedPage == nil)
    }


    @Test
    func loadPageHandlesConcurrentLoads() async throws {
        let mockLoader = MockSequentialPageLoader<MockOffsetPage>()
        let page1 = MockOffsetPage()
        page1.pageOffsetStub = Stub(defaultReturnValue: 0)
        let page2 = MockOffsetPage()
        page2.pageOffsetStub = Stub(defaultReturnValue: 0)

        mockLoader.loadPageStub = ThrowingStub(
            defaultReturnValue: page2,
            resultQueue: [.success(page1)]
        )

        // Add delay to allow both calls to get past cache check
        mockLoader.loadPagePrologue = {
            try await Task.sleep(for: .seconds(0.5))
        }

        let pager = SequentialPager(pageLoader: mockLoader)

        // Start two concurrent loads of the same page
        async let firstLoad = pager.loadPage(after: nil)
        async let secondLoad = pager.loadPage(after: nil)

        let (first, second) = try await (firstLoad, secondLoad)

        #expect(first != second)
        #expect(pager.loadedPages == [page1] || pager.loadedPages == [page2])
        #expect(mockLoader.loadPageStub.callArguments == [nil, nil])
    }
}
