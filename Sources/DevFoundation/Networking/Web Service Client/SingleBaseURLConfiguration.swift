//
//  SingleBaseURLConfiguration.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/17/25.
//

import Foundation


/// A base URL configuration that has a single URL.
public struct SingleBaseURLConfiguration: BaseURLConfiguring {
    public typealias BaseURL = Void

    /// The configuration’s single base URL.
    public let baseURL: URL

    
    /// Creates a new single base URL configuration with the specified URL.
    ///
    /// - Parameter baseURL: The single base URL that the configuration has.
    public init(baseURL: URL) {
        self.baseURL = baseURL
    }


    public func url(for _: BaseURL) -> URL {
        return baseURL
    }
}
