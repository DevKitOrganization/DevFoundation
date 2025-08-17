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
/// and an ``HTTPClient`` to load requests. Web service requests are expressed as types that conform to
/// ``WebServiceRequest``, which provide the components of the request itself as well as a function for handling the
/// response.
///
/// To make using a web service client more convenient, we suggest creating a type alias so that you don’t have to
/// type out generic parameters. For example,
///
///     typealias SpacelyWebServiceClient = WebServiceClient<SpacelyBaseURLConfiguration, SpacelyRequestContext>
public final class WebServiceClient<BaseURLConfiguration, RequestContext>: Sendable
where BaseURLConfiguration: BaseURLConfiguring, RequestContext: Sendable {
    /// The HTTP client that the web service client uses to load its requests.
    public let httpClient: HTTPClient<RequestContext>

    /// The base URL configuration that the web service client uses to create its requests.
    public let baseURLConfiguration: BaseURLConfiguration


    /// Creates a new web service client with the specified HTTP client and base URL configuration.
    ///
    /// - Parameters:
    ///   - httpClient: The HTTP client that the web service client uses to load its requests.
    ///   - baseURLConfiguration: The base URL configuration that the web service client uses to create its request.
    public init(
        httpClient: HTTPClient<RequestContext>,
        baseURLConfiguration: BaseURLConfiguration,
    ) {
        self.httpClient = httpClient
        self.baseURLConfiguration = baseURLConfiguration
    }


    /// Loads a request and returns its mapped response.
    ///
    /// This function works by creating a URL request for the web service request by calling
    /// ``WebServiceRequest/urlRequest(with:)`` with the client’s base URL configuration. Then, the client loads that
    /// URL request using its HTTP client and the request’s context. Finally, the response is mapped using
    /// ``WebServiceRequest/mapResponse(_:)`` and returned.
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
        Request.Context == RequestContext
    {
        let urlRequest = try request.urlRequest(with: baseURLConfiguration)
        let response = try await httpClient.load(
            urlRequest,
            context: request.context
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
        using client: WebServiceClient<BaseURLConfiguration, Context>
    ) async throws -> MappedResponse {
        return try await client.load(self)
    }
}
