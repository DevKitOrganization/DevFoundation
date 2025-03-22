//
//  BaseURLConfiguring.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/17/25.
//

import Foundation


/// A type that provides a way to refer to a web service’s base URLs symbolically and to get the real URLs for those
/// symbols.
///
/// Base URL configurations allow web service requests to refer to their base URLs symbolically, but for a web service
/// client to resolve those symbolic base URLs to actual URLs when loading a request. Each base URL configuration has an
/// associated type called `BaseURL` which represents the symbolic base URL; these are typically just simple enums with
/// a case representing different APIs or API versions. For example,
///
///     struct SpacelyBaseURLConfiguration: BaseURLConfiguring {
///         enum BaseURL {
///             case astro
///             case elroy
///             case rosie
///         }
///
///         …
///     }
///
/// Types conforming to ``WebServiceRequest`` return one of these enum cases in their ``WebServiceRequest/baseURL``
/// property. The base URL configuration implements ``url(for:)`` to return the actual URLs for each case.
///
///     struct SpacelyBaseURLConfiguration: BaseURLConfiguring {
///         let subdomain: String
///
///
///         func url(for baseURL: BaseURL) -> URL {
///             let suffix = switch baseURL {
///             case .astro:
///                 "/astro/v1"
///             case .elroy:
///                 "/elroy/v3"
///             case .rosie:
///                 "/rosie/v4"
///             }
///
///             return URL(string: "https://\(subdomain).spacely.com/rest/\(suffix)")!
///         }
///     }
///
/// You can create a different instance of this for each of your backend environments. For example, you might have one
/// for preproduction, staging, and production:
///
///     extension SpacelyBaseURLConfiguration {
///         static let preproduction = BaseURLConfiguration(subdomain: "api-preprod")
///         static let staging = BaseURLConfiguration(subdomain: "api-staging")
///         static let production = BaseURLConfiguration(subdomain: "api")
///     }
///
/// When you create your web service client, you can use `.preproduction`, `.staging`, or `.production` as your base URL
/// configuration without having to change any of your web service requests.
///
/// For web services that have a single base URL, you can use ``SingleBaseURLConfiguration``.
public protocol BaseURLConfiguring: Sendable {
    /// A type that describes the available base URLs.
    ///
    /// This type is typically a simple enum with a case for each base URL that a web service supports.
    associatedtype BaseURL

    /// Returns the real URL corresponding a base URL.
    ///
    /// This function is used to construct a `URLRequest` from a web service request.
    ///
    /// - Parameter baseURL: The symbolic base URL for which to get a real URL.
    func url(for baseURL: BaseURL) -> URL
}
