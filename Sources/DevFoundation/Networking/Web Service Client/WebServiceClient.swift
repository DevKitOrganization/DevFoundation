//
//  WebServiceClient.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/17/25.
//

import Foundation

/// A client for a web service.
///
/// Web service clients provides a declarative approach for accessing a web service. The client itself is simple:
/// it has an instance of ``BaseURLConfiguring`` that describes the various base URLs that the web service supports,
/// and an ``AuthenticatingHTTPClient`` to load requests. Web service requests are expressed as types that conform to
/// ``WebServiceRequest``, which provide the components of the request itself as well as a function for handling the
/// response.
///
/// To make using a web service client more convenient, we suggest creating a type alias so that you don’t have to
/// type out generic parameters. For example,
///
///     typealias SpacelyWebServiceClient = WebServiceClient<SpacelyBaseURLConfiguration, SpacelyAuthenticator>
public final class WebServiceClient<BaseURLConfiguration, Authenticator>: Sendable
where BaseURLConfiguration: BaseURLConfiguring, Authenticator: HTTPRequestAuthenticator {
    /// The authenticating HTTP client that the web service client uses to load its requests.
    public let authenticatingHTTPClient: AuthenticatingHTTPClient<Authenticator>

    /// The base URL configuration that the web service client uses to create its requests.
    public let baseURLConfiguration: BaseURLConfiguration


    /// Creates a new web service client with the specified properties.
    ///
    /// - Parameters:
    ///   - urlRequestLoader: The web service client’s underlying URL request loader.
    ///   - authenticator: The HTTP request authenticator that the web service client uses to authenticate its requests.
    ///   - baseURLConfiguration: The base URL configuration that the web service client uses to create its request.
    ///   - requestInterceptors: The web service client’s request interceptors. By default, a client has no request
    ///     interceptors.
    ///   - responseInterceptors: The web service client’s response interceptors. By default, a client has no request
    ///     interceptors.
    public init(
        urlRequestLoader: any URLRequestLoader,
        authenticator: Authenticator,
        baseURLConfiguration: BaseURLConfiguration,
        requestInterceptors: [any HTTPClientRequestInterceptor] = [],
        responseInterceptors: [any HTTPClientResponseInterceptor] = []
    ) {
        self.authenticatingHTTPClient = AuthenticatingHTTPClient(
            urlRequestLoader: urlRequestLoader,
            authenticator: authenticator,
            requestInterceptors: requestInterceptors,
            responseInterceptors: responseInterceptors
        )
        self.baseURLConfiguration = baseURLConfiguration
    }


    /// The web service client’s underlying URL request loader.
    public var urlRequestLoader: any URLRequestLoader {
        return authenticatingHTTPClient.urlRequestLoader
    }


    /// The HTTP request authenticator that the web service client uses to authenticate its requests.
    public var authenticator: Authenticator {
        return authenticatingHTTPClient.authenticator
    }


    /// The web service client’s request interceptors.
    public var requestInterceptors: [any HTTPClientRequestInterceptor] {
        return authenticatingHTTPClient.requestInterceptors
    }


    /// The web service client’s response interceptors.
    public var responseInterceptors: [any HTTPClientResponseInterceptor] {
        return authenticatingHTTPClient.responseInterceptors
    }


    /// Loads a request and returns its mapped response.
    ///
    /// This function works by creating a URL request for the web service request by calling
    /// ``WebServiceRequest/urlRequest(with:)`` with the client’s base URL configuration. Then, the client loads that
    /// URL request using its authenticating HTTP client and the request’s authenticator context. Finally, the response
    /// is mapped using ``WebServiceRequest/mapResponse(_:)`` and returned.
    ///
    /// ``WebServiceRequest/load(using:)`` provides an alternative syntax for loading a request, but switches the order
    /// of the client and the request at the call site, which may be desirable in certain cases. Neither form is more
    /// correct than the other.
    ///
    /// - Parameter request: The web service request to load.
    public func load<Request>(
        _ request: Request
    ) async throws -> Request.MappedResponse
    where
        Request: WebServiceRequest,
        Request.BaseURLConfiguration == BaseURLConfiguration,
        Request.Authenticator == Authenticator
    {
        let urlRequest = try request.urlRequest(with: baseURLConfiguration)
        let response = try await authenticatingHTTPClient.load(
            urlRequest,
            authenticatorContext: request.authenticatorContext
        )
        return try request.mapResponse(response)
    }
}


extension WebServiceRequest {
    /// Loads the request with a client and returns its mapped response.
    ///
    /// This function is equivalent to calling ``WebServiceClient/load(_:)``, but switches the order of the client and
    /// the request at the call site. This can eliminate nested parentheses in some cases, which may be desirable.
    /// Neither form is more correct than the other.
    ///
    /// - Parameter client: The web service client with which to load the request.
    public func load(
        using client: WebServiceClient<BaseURLConfiguration, Authenticator>
    ) async throws -> MappedResponse {
        return try await client.load(self)
    }
}
