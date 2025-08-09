//
//  RandomAccessPagerTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/9/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct RandomAccessPagerTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    func initializationSetsUpEmptyPager() {
        let mockLoader = MockRandomAccessPageLoader<MockOffsetPage>()
        let pager = RandomAccessPager(pageLoader: mockLoader)

        #expect(pager.loadedPages.isEmpty)
        #expect(pager.lastLoadedPage == nil)
        #expect(pager.lastLoadedPageOffset == nil)
    }


    @Test
    mutating func pageExistsDelegatesToLoader() {
        let mockLoader = MockRandomAccessPageLoader<MockOffsetPage>()
        mockLoader.pageExistsStub = Stub(defaultReturnValue: true)

        let pager = RandomAccessPager(pageLoader: mockLoader)
        let offset = randomInt(in: 0 ... 100)

        #expect(pager.pageExists(at: offset))
        #expect(mockLoader.pageExistsStub.callArguments == [offset])
    }


    @Test
    mutating func pageExistsAfterUsesDefaultImplementation() {
        let mockLoader = MockRandomAccessPageLoader<MockOffsetPage>()
        mockLoader.pageExistsStub = Stub(defaultReturnValue: false)

        let pageOffset = randomInt(in: 0 ... 100)
        let page = MockOffsetPage()
        page.pageOffsetStub = Stub(defaultReturnValue: pageOffset)

        #expect(!mockLoader.pageExists(after: page))
        #expect(mockLoader.pageExistsStub.callArguments == [pageOffset + 1])
    }


    @Test
    mutating func loadPageAtLoadsPage() async throws {
        let mockLoader = MockRandomAccessPageLoader<MockOffsetPage>()
        let offset = randomInt(in: 0 ... 100)
        let expectedPage = MockOffsetPage()
        expectedPage.pageOffsetStub = Stub(defaultReturnValue: offset)
        mockLoader.loadPageStub = ThrowingStub(defaultResult: .success(expectedPage))

        let pager = RandomAccessPager(pageLoader: mockLoader)

        let loadedPage = try await pager.loadPage(at: offset)

        #expect(loadedPage === expectedPage)
        #expect(pager.loadedPages == [expectedPage])
        #expect(pager.lastLoadedPage === expectedPage)
        #expect(pager.lastLoadedPageOffset == offset)
        #expect(mockLoader.loadPageStub.callArguments == [offset])
    }


    @Test
    mutating func loadPageAfterWithPageUsesDefaultImplementation() async throws {
        let mockLoader = MockRandomAccessPageLoader<MockOffsetPage>()
        let pageOffset = randomInt(in: 0 ... 100)
        let nextOffset = pageOffset + 1
        let expectedPage = MockOffsetPage()
        expectedPage.pageOffsetStub = Stub(defaultReturnValue: nextOffset)
        mockLoader.loadPageStub = ThrowingStub(defaultResult: .success(expectedPage))

        let page = MockOffsetPage()
        page.pageOffsetStub = Stub(defaultReturnValue: pageOffset)

        let loadedPage = try await mockLoader.loadPage(after: page)

        #expect(loadedPage === expectedPage)
        #expect(mockLoader.loadPageStub.callArguments == [nextOffset])
    }


    @Test
    mutating func loadPageAfterWithNilUsesDefaultImplementation() async throws {
        let mockLoader = MockRandomAccessPageLoader<MockOffsetPage>()
        let expectedPage = MockOffsetPage()
        expectedPage.pageOffsetStub = Stub(defaultReturnValue: 0)
        mockLoader.loadPageStub = ThrowingStub(defaultResult: .success(expectedPage))

        let loadedPage = try await mockLoader.loadPage(after: nil)

        #expect(loadedPage === expectedPage)
        #expect(mockLoader.loadPageStub.callArguments == [0])
    }


    @Test
    mutating func loadPageAtReturnsCachedPage() async throws {
        let mockLoader = MockRandomAccessPageLoader<MockOffsetPage>()
        let offset = randomInt(in: 0 ... 100)
        let page = MockOffsetPage()
        page.pageOffsetStub = Stub(defaultReturnValue: offset)
        mockLoader.loadPageStub = ThrowingStub(defaultResult: .success(page))

        let pager = RandomAccessPager(pageLoader: mockLoader)

        // Load page first time
        _ = try await pager.loadPage(at: offset)

        // Load same page again - should return cached version
        let cachedPage = try await pager.loadPage(at: offset)

        #expect(cachedPage === page)
        #expect(pager.loadedPages == [page])
        #expect(mockLoader.loadPageStub.callArguments == [offset])    // Only called once
    }


    @Test
    mutating func loadPageAtMaintainsOrder() async throws {
        let mockLoader = MockRandomAccessPageLoader<MockOffsetPage>()
        let offset0 = randomInt(in: 0 ... 30)
        let offset1 = randomInt(in: 31 ... 60)
        let offset2 = randomInt(in: 61 ... 100)

        let page0 = MockOffsetPage()
        page0.pageOffsetStub = Stub(defaultReturnValue: offset0)
        let page1 = MockOffsetPage()
        page1.pageOffsetStub = Stub(defaultReturnValue: offset1)
        let page2 = MockOffsetPage()
        page2.pageOffsetStub = Stub(defaultReturnValue: offset2)

        mockLoader.loadPageStub = ThrowingStub(
            defaultResult: .success(page1),
            resultQueue: [.success(page2), .success(page0)]
        )

        let pager = RandomAccessPager(pageLoader: mockLoader)

        // Load pages out of order
        _ = try await pager.loadPage(at: offset2)
        _ = try await pager.loadPage(at: offset0)
        _ = try await pager.loadPage(at: offset1)

        // Pages should be ordered by offset
        #expect(pager.loadedPages == [page0, page1, page2])
        #expect(pager.lastLoadedPageOffset == offset2)
    }


    @Test
    mutating func loadPageAtThrowsError() async {
        let mockLoader = MockRandomAccessPageLoader<MockOffsetPage>()
        let offset = randomInt(in: 0 ... 100)
        let expectedError = randomError()
        mockLoader.loadPageStub = ThrowingStub(defaultResult: .failure(expectedError))

        let pager = RandomAccessPager(pageLoader: mockLoader)

        await #expect(throws: expectedError) {
            try await pager.loadPage(at: offset)
        }

        #expect(pager.loadedPages.isEmpty)
        #expect(pager.lastLoadedPageOffset == nil)
    }


    @Test
    mutating func loadPageAtHandlesConcurrentLoads() async throws {
        let mockLoader = MockRandomAccessPageLoader<MockOffsetPage>()
        let offset = randomInt(in: 0 ... 100)
        let page1 = MockOffsetPage()
        page1.pageOffsetStub = Stub(defaultReturnValue: offset)
        let page2 = MockOffsetPage()
        page2.pageOffsetStub = Stub(defaultReturnValue: offset)

        mockLoader.loadPageStub = ThrowingStub(
            defaultResult: .success(page2),
            resultQueue: [.success(page1)]
        )

        // Add delay to allow both calls to get past cache check
        mockLoader.loadPagePrologue = {
            try await Task.sleep(for: .seconds(0.5))
        }

        let pager = RandomAccessPager(pageLoader: mockLoader)

        // Start two concurrent loads of the same page
        async let firstLoad = pager.loadPage(at: offset)
        async let secondLoad = pager.loadPage(at: offset)

        let (first, second) = try await (firstLoad, secondLoad)

        #expect(first != second)
        #expect(pager.loadedPages == [page1] || pager.loadedPages == [page2])
        #expect(mockLoader.loadPageStub.callArguments == [offset, offset])
    }
}
