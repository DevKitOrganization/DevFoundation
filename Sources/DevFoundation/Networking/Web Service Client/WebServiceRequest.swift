//
//  WebServiceRequest.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/17/25.
//

import Foundation

/// A type that describes the parts of a web service request and how to handle the response.
///
/// `WebServiceRequest` provides a declarative interface for creating URL requests and handling their responses. This
/// makes it much easier to create and test requests, and enables DevFoundation to create URL requests uniformly.
///
/// Web service requests have the following properties:
///
///   - An HTTP method.
///   - An array of HTTP header items.
///   - Contextual information about the request.
///   - A base URL.
///   - An array of path components used to create a path relative to the base URL.
///   - An optional URL fragment.
///   - An array of query items.
///   - An optional HTTP body.
///
/// Web service requests are also responsible for response handling with ``mapResponse(_:)``. This function typically
/// deserializes the response body into some other data type or throws an error.
///
/// DevFoundation provides ``JSONBodyWebServiceRequest`` to conveniently create web service requests with JSON bodies.
/// Similar protocols can be created for other body types, e.g., Protobuf or XML.
public protocol WebServiceRequest: Sendable {
    /// The type of request context that the web service request requires.
    associatedtype Context: Sendable

    /// The base URL configuration the web service request requires.
    associatedtype BaseURLConfiguration: BaseURLConfiguring

    /// The type of response that the web service request produces.
    ///
    /// This is most often an ``HTTPResponse`` with a specific body type.
    associatedtype MappedResponse

    /// The HTTP method for the web service request.
    var httpMethod: HTTPMethod { get }

    /// The web service request’s HTTP header items.
    ///
    /// Defaults to `[]`
    var headerItems: [HTTPHeaderItem] { get }

    /// Contextual information about the request.
    ///
    /// A default implementation of this function is provided if `Context` is `Void`.
    var context: Context { get }

    /// The web service request’s base URL.
    ///
    /// A default implementation of this function is provided if `BaseURLConfiguration.BaseURL` is `Void`.
    var baseURL: BaseURLConfiguration.BaseURL { get }

    /// The path components of the web service request’s URL relative to its base URL.
    ///
    /// Path components are automatically percent-encoded when a URL request is created, and thus should not be
    /// percent-encoded in advance.
    var pathComponents: [URLPathComponent] { get }

    /// The URL fragment for the web service request.
    ///
    /// Defaults to `nil`.
    var fragment: String? { get }

    /// The web service request’s URL query items.
    ///
    /// Defaults to `[]`.
    var queryItems: [URLQueryItem] { get }

    /// Whether the web service request automatically percent-encodes query items.
    ///
    /// Defaults to `true`.
    var automaticallyPercentEncodesQueryItems: Bool { get }

    /// The web service request’s HTTP body.
    ///
    /// Defaults to `nil`.
    var httpBody: HTTPBody? { get throws }

    /// Maps a response to a more specific type.
    func mapResponse(_ response: HTTPResponse<Data>) throws -> MappedResponse
}


// MARK: - Default Implementations

extension WebServiceRequest {
    public var headerItems: [HTTPHeaderItem] {
        return []
    }


    public var fragment: String? {
        return nil
    }


    public var queryItems: [URLQueryItem] {
        return []
    }


    public var httpBody: HTTPBody? {
        get throws {
            return nil
        }
    }


    public var automaticallyPercentEncodesQueryItems: Bool {
        return true
    }
}


extension WebServiceRequest where BaseURLConfiguration.BaseURL == Void {
    public var baseURL: Void {
        return ()
    }
}


extension WebServiceRequest where Context == Void {
    public var context: Void {
        return ()
    }
}


// MARK: - Creating a URL Request

extension WebServiceRequest {
    /// Creates a new URL request using the specified base URL configuration.
    ///
    /// - Parameter baseURLConfiguration: The configuration from which to get a base URL for the request.
    /// - Throws: Throws an ``InvalidWebServiceRequestError`` if the URL request could not be created for any reason.
    public func urlRequest(with baseURLConfiguration: BaseURLConfiguration) throws -> URLRequest {
        guard let url = url(with: baseURLConfiguration) else {
            // This line is likely impossible to hit given how we’ve written the url(with:) function
            throw InvalidWebServiceRequestError(debugDescription: "could not create the request’s URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.httpHeaderItems = headerItems

        do {
            if let httpBody = try httpBody {
                request.httpBody = httpBody.data
                request.setHTTPHeaderValue(httpBody.contentType.rawValue, for: .contentType)
            }
        } catch {
            throw InvalidWebServiceRequestError(
                debugDescription: "could not create the request’s HTTP body",
                underlyingError: error
            )
        }

        return request
    }


    /// Returns the request’s URL using the specified base URL configuration.
    ///
    /// - Parameter baseURLConfiguration: The configuration from which to get a base URL for the request.
    /// - Returns: The request’s URL, or `nil` if a URL could not be constructed.
    private func url(with baseURLConfiguration: BaseURLConfiguration) -> URL? {
        let baseURL = baseURLConfiguration.url(for: baseURL)
        let path = pathComponents.map(\.rawValue).joined(separator: "/")

        guard
            let percentEncodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
            let url = percentEncodedPath.isEmpty ? baseURL : URL(string: percentEncodedPath, relativeTo: baseURL),
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        else {
            // This line is likely impossible to hit given how we’ve written this code
            return nil
        }

        urlComponents.fragment = fragment

        if !queryItems.isEmpty {
            if automaticallyPercentEncodesQueryItems {
                urlComponents.queryItems = queryItems
            } else {
                urlComponents.percentEncodedQueryItems = queryItems
            }
        }

        return urlComponents.url
    }
}
