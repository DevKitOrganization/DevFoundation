//
//  OffsetPage.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/8/25.
//

import Foundation

/// A type that has an offset from the first item in a page sequence.
public protocol OffsetPage: Sendable {
    /// The offset of the page from the first page.
    ///
    /// The first page has a page offset of 0.
    var pageOffset: Int { get }
}


extension OffsetPage {
    /// The offset of the next page.
    ///
    /// This is equivalent to `pageOffset + 1`.
    public var nextPageOffset: Int {
        pageOffset + 1
    }
}
