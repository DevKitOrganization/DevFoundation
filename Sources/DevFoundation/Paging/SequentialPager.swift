//
//  SequentialPager.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/8/25.
//

import Foundation
import Synchronization

/// A type that can load pages on behalf of a sequential pager.
public protocol SequentialPageLoader<Page>: Sendable {
    /// The type of page that is loaded.
    associatedtype Page: OffsetPage

    /// Returns whether a page exists after a given page.
    ///
    /// - Parameter page: The page immediately preceding the one whose existence is being checked.
    func pageExists(after page: Page) -> Bool

    /// Loads the page after a given page.
    ///
    /// If `page` is `nil`, loads the first page.
    ///
    /// It is a programming error to call this function with a page for which ``pageExists(after:)`` returns false.
    /// Conforming types should trap if this happens.
    ///
    /// - Parameter page: The page immediately preceding the one being loaded.
    func loadPage(after page: Page?) async throws -> Page
}


/// A type that can load pages sequentially and provide fast access to previously loaded pages.
///
/// This protocol exists so that random access pagers can be used in generic algorithms requiring sequential paging
/// functionality. In general, you should use ``SequentialPager`` or ``RandomAccessPager`` instead of creating your own
/// conforming type.
public protocol SequentialPaging<Page>: SequentialPageLoader {
    /// The pages that have been previously loaded.
    var loadedPages: [Page] { get }

    /// The last loaded page.
    ///
    /// This is the loaded page with the greatest page offset. If `nil`, no pages have been loaded. A default
    /// implementation is provided that simply returns `loadedPages.last`.
    var lastLoadedPage: Page? { get }
}


extension SequentialPaging {
    public var lastLoadedPage: Page? {
        return loadedPages.last
    }
}


/// A sequential page loader that provides fast access to previously loaded pages.
///
/// Each sequential pager uses a ``SequentialPageLoader`` to load pages on its behalf. You will typically create custom
/// page loaders that, e.g., fetch pages from a web service, and use a `SequentialPager` to load those pages as needed
/// and provide access to them.
public final class SequentialPager<Page>: SequentialPaging where Page: OffsetPage {
    /// The page loader that the pager uses to load its pages.
    private let pageLoader: any SequentialPageLoader<Page>

    /// A mutex that synchronizes access to the instance’s loaded pages.
    private let loadedPagesMutex: Mutex<[Page]>


    /// Creates a new sequential pager with the specified page loader.
    ///
    /// - Parameters:
    ///   - pageLoader: The page loader to use to load pages.
    ///   - loadedPages: Any pages that have already been loaded. `[]` by default.
    ///
    ///     For each page in this array, the page’s offset must be the same as its index in the array. That is,
    ///     `loadedPages[i].pageOffset` must be `i`.
    public init(pageLoader: some SequentialPageLoader<Page>, loadedPages: [Page] = []) {
        precondition(
            loadedPages.enumerated().allSatisfy { (index, page) in page.pageOffset == index },
            "loaded pages must start at offset 0 and be consecutive"
        )

        self.pageLoader = pageLoader
        self.loadedPagesMutex = .init(loadedPages)
    }


    public var loadedPages: [Page] {
        return loadedPagesMutex.withLock { $0 }
    }


    public func pageExists(after page: Page) -> Bool {
        return pageLoader.pageExists(after: page)
    }


    public func loadPage(after page: Page?) async throws -> Page {
        let pageOffset = page?.nextPageOffset ?? 0

        if let loadedPage = loadedPagesMutex.withLock({ pageOffset < $0.endIndex ? $0[pageOffset] : nil }) {
            return loadedPage
        }

        let loadedPage = try await pageLoader.loadPage(after: page)

        loadedPagesMutex.withLock { (loadedPages) in
            if pageOffset >= loadedPages.count {
                loadedPages.append(loadedPage)
            } else {
                loadedPages[pageOffset] = loadedPage
            }
        }

        return loadedPage
    }
}
