//
//  RandomAccessPager.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/8/25.
//

import Foundation
import Synchronization

/// A type that can load pages on behalf of a random access pager.
public protocol RandomAccessPageLoader<Page>: SequentialPageLoader {
    /// Returns whether a page exists at the given offset.
    ///
    /// - Parameter offset: The offset of the page whose existence is being checked.
    func pageExists(at offset: Int) -> Bool

    /// Loads the page at a given offset.
    ///
    /// It is a programming error to call this function with a page for which ``pageExists(at:)`` returns false.
    /// Conforming types should trap if this happens.
    ///
    /// - Parameter offset: The offset of the page to load. The first page is at offset 0.
    func loadPage(at offset: Int) async throws -> Page
}


extension RandomAccessPageLoader {
    public func pageExists(after page: Page) -> Bool {
        return pageExists(at: page.nextPageOffset)
    }


    public func loadPage(after page: Page?) async throws -> Page {
        return try await loadPage(at: page?.nextPageOffset ?? 0)
    }
}


/// A type that can load pages in any order and provide fast access to previously loaded pages.
///
/// In general, you should use a ``RandomAccessPager`` instead of creating your own conforming type.
public protocol RandomAccessPaging<Page>: RandomAccessPageLoader, SequentialPaging {
    /// The page offset of the last loaded page.
    ///
    /// In this context, last refers to the largest page offset, not the most recently loaded page.
    var lastLoadedPageOffset: Int? { get }
}


/// A random access page loader that provides fast access to previously loaded pages.
///
/// Each random access pager uses a ``RandomAccessPageLoader`` to load pages on its behalf. You will typically create
/// custom page loaders that, e.g., fetch pages from a web service, and use a `RandomAccessPager` to load those pages as
/// needed and provide access to them.
public final class RandomAccessPager<Page>: RandomAccessPaging where Page: OffsetPage {
    private struct LoadedPages {
        var loadedPagesByOffset: [Int: Page] = [:]
        var lastLoadedPageOffset: Int?
    }


    /// The page loader that the pager uses to load its pages.
    private let pageLoader: any RandomAccessPageLoader<Page>

    /// A mutex that synchronizes access to the instance’s loaded pages.
    ///
    /// This dictionary is ordered by loaded page’s page offsets.
    private let loadedPagesMutex: Mutex<LoadedPages>


    /// Creates a new sequential pager with the specified page loader.
    ///
    /// - Parameters:
    ///   - pageLoader: The page loader to use to load pages.
    ///   - loadedPages: Any pages that have already been loaded. `[]` by default.
    public init(pageLoader: some RandomAccessPageLoader<Page>, loadedPages: [Page] = []) {
        self.pageLoader = pageLoader

        var pages = LoadedPages()
        for page in loadedPages {
            pages.loadedPagesByOffset[page.pageOffset] = page
            pages.lastLoadedPageOffset = max(pages.lastLoadedPageOffset ?? .min, page.pageOffset)
        }
        self.loadedPagesMutex = .init(pages)
    }


    public var loadedPages: [Page] {
        return loadedPagesMutex.withLock { (loadedPages) in
            loadedPages.loadedPagesByOffset.values.sorted { $0.pageOffset < $1.pageOffset }
        }
    }


    public var lastLoadedPageOffset: Int? {
        return loadedPagesMutex.withLock(\.lastLoadedPageOffset)
    }


    public func pageExists(at offset: Int) -> Bool {
        return pageLoader.pageExists(at: offset)
    }


    public func loadPage(at offset: Int) async throws -> Page {
        if let loadedPage = loadedPagesMutex.withLock({ $0.loadedPagesByOffset[offset] }) {
            return loadedPage
        }

        let loadedPage = try await pageLoader.loadPage(at: offset)
        loadedPagesMutex.withLock { (loadedPages) in
            loadedPages.loadedPagesByOffset[offset] = loadedPage
            loadedPages.lastLoadedPageOffset = max(loadedPages.lastLoadedPageOffset ?? .min, loadedPage.pageOffset)
        }
        return loadedPage
    }
}
