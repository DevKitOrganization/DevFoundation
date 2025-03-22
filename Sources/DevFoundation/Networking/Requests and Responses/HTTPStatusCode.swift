//
//  HTTPStatusCode.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/13/25.
//

import Foundation


/// A type-safe representation of an HTTP status code.
public struct HTTPStatusCode: TypedExtensibleEnum {
    public let rawValue: Int


    public init(_ rawValue: Int) {
        self.rawValue = rawValue
    }


    /// Whether the status code is informational (1xx).
    public var isInformational: Bool {
        return (100 ..< 200).contains(rawValue)
    }


    /// Whether status code indicates success (2xx).
    public var isSuccessful: Bool {
        return (200 ..< 300).contains(rawValue)
    }


    /// Whether the status code indicates a redirection (3xx).
    public var isRedirection: Bool {
        return (300 ..< 400).contains(rawValue)
    }


    /// Whether the status code indicates a client error (4xx).
    public var isClientError: Bool {
        return (400 ..< 500).contains(rawValue)
    }


    /// Whether the status code indicates a server error (5xx).
    public var isServerError: Bool {
        return (500 ..< 600).contains(rawValue)
    }


    /// Whether the status code indicates an error (4xx or 5xx).
    public var isError: Bool {
        return isClientError || isServerError
    }
}



// Most of this documentation is lifted directly from RFC-9110.
extension HTTPStatusCode {
    /// A 100 status code, which indicates that the initial part of a request has been received and has not yet been
    /// rejected by the server.
    public static let `continue` = HTTPStatusCode(100)

    /// A 101 status code, which indicates that the server understands and is willing to comply with the client's
    /// request for a change in the application protocol being used on this connection.
    public static let switchingProtocols = HTTPStatusCode(101)

    /// A 200 status code, which indicates that the request has succeeded.
    public static let ok = HTTPStatusCode(200)

    /// A 201 status code, which indicates that the request has been fulfilled and has resulted in one or more new
    /// resources being created.
    public static let created = HTTPStatusCode(201)

    /// A 202 status code, which that the request has been accepted for processing, but the processing has not been
    /// completed.
    public static let accepted = HTTPStatusCode(202)

    /// A 203 status code, which indicates that the request was successful but the enclosed content has been modified
    /// from that of the origin server’s ``ok`` response by a transforming proxy.
    public static let nonAuthoritativeInformation = HTTPStatusCode(203)

    /// A 204 status code, which indicates that the server has successfully fulfilled the request and that there is no
    /// additional content to send in the response content.
    public static let noContent = HTTPStatusCode(204)

    /// A 205 status code, which indicates that the server has fulfilled the request and desires that the user agent
    /// reset the document view to its original state as received from the origin server.
    public static let resetContent = HTTPStatusCode(205)

    /// A 206 status code, which indicates that the server is successfully fulfilling a range request for the target
    /// resource by transferring one or more parts of the selected representation.
    public static let partialContent = HTTPStatusCode(206)

    /// A 300 status code, which indicates that the target resource has more than one representation.
    public static let multipleChoices = HTTPStatusCode(300)

    /// A 301 status code, which indicates that the target resource has been assigned a new permanent URI.
    public static let movedPermanently = HTTPStatusCode(301)

    /// A 302 status code, which indicates indicates that the target resource resides temporarily under a different URI.
    public static let found = HTTPStatusCode(302)

    /// A 303 status code, which indicates that the server is redirecting the user agent to a different resource.
    public static let seeOther = HTTPStatusCode(303)

    /// A 304 status code, which indicates that a conditional GET or HEAD request has been received and would have
    /// resulted in an ``ok`` response if it were not for the fact that the condition evaluated to false.
    public static let notModified = HTTPStatusCode(304)

    /// A 307 status code, which indicates that the target resource resides temporarily under a different URI and the
    /// user agent _must not_ change the request method if it performs an automatic redirection to that URI.
    public static let temporaryRedirect = HTTPStatusCode(307)

    /// A 308 status code, which indicates that the target resource has been assigned a new permanent URI and any future
    /// references to this resource ought to use one of the enclosed URIs.
    public static let permanentRedirect = HTTPStatusCode(308)

    /// A 400 status code, which indicates that the server cannot or will not process the request due to something that
    /// is perceived to be a client error.
    public static let badRequest = HTTPStatusCode(400)

    /// A 401 status code, which indicates that the request has not been applied because it lacks valid authentication
    /// credentials for the target resource.
    public static let unauthorized = HTTPStatusCode(401)

    /// A 403 status code, which indicates that the server understood the request but refuses to fulfill it.
    public static let forbidden = HTTPStatusCode(403)

    /// A 404 status code, which indicates that the origin server did not find a current representation for the target
    /// resource or is not willing to disclose that one exists.
    public static let notFound = HTTPStatusCode(404)

    /// A 405 status code, which indicates that the method received in the request-line is known by the origin server
    /// but not supported by the target resource.
    public static let methodNotAllowed = HTTPStatusCode(405)

    /// A 406 status code, which indicates that the target resource does not have a current representation that would be
    /// acceptable to the user agent and the server is unwilling to supply a default representation..
    public static let unacceptable = HTTPStatusCode(406)

    /// A 407 status code, which indicates that the client needs to authenticate itself in order to use a proxy for this
    /// request.
    public static let proxyAuthenticationRequired = HTTPStatusCode(407)

    /// A 408 status code, which indicates that the server did not receive a complete request message within the time
    /// that it was prepared to wait.
    public static let requestTimedOut = HTTPStatusCode(408)

    /// A 409 status code, which indicates that the request could not be completed due to a conflict with the current
    /// state of the target resource.
    public static let conflict = HTTPStatusCode(409)

    /// A 410 status code, which indicates that access to the target resource is no longer available at the origin
    /// server and that this condition is likely to be permanent.
    public static let gone = HTTPStatusCode(410)

    /// A 411 status code, which indicates that the server refuses to accept the request without a defined
    /// Content-Length header.
    public static let lengthRequired = HTTPStatusCode(411)

    /// A 412 status code, which indicates that one or more conditions given in the request header fields evaluated to
    /// false when tested on the server.
    public static let preconditionFailed = HTTPStatusCode(412)

    /// A 413 status code, which indicates that the server is refusing to process a request because the request content
    /// is larger than the server is willing or able to process.
    public static let contentTooLarge = HTTPStatusCode(413)

    /// A 414 status code, which indicates that the server is refusing to service the request because the target URI is
    /// longer than the server is willing to interpret.
    public static let requestedURITooLong = HTTPStatusCode(414)

    /// A 415 status code, which indicates that the origin server is refusing to service the request because the content
    /// is in a format not supported by this method on the target resource.
    public static let unsupportedMediaType = HTTPStatusCode(415)

    /// A 416 status code, which indicates that the set of ranges in the request’s Range header field has been rejected
    /// either because none of the requested ranges are satisfiable or because the client has requested an excessive
    /// number of small or overlapping ranges.
    public static let rangeNotSatisfiable = HTTPStatusCode(416)

    /// A 417 status code, which indicates that the expectation given in the request's Expect header field could not be
    /// met by at least one of the inbound servers.
    public static let expectationFailed = HTTPStatusCode(417)

    /// A 421 status code, which indicates that the request was directed at a server that is unable or unwilling to
    /// produce an authoritative response for the target URI.
    public static let misdirectedRequest = HTTPStatusCode(421)

    /// A 422 status code, which indicates that the server understands the content type of the request content, and the
    /// syntax of the request content is correct, but it was unable to process the contained instructions.
    public static let unprocessableContent = HTTPStatusCode(422)

    /// A 426 status code, which indicates that the server refuses to perform the request using the current protocol
    /// but might be willing to do so after the client upgrades to a different protocol.
    public static let upgradeRequired = HTTPStatusCode(426)

    /// A 500 status code, which indicates that the server encountered an unexpected condition that prevented it from
    /// fulfilling the request.
    public static let internalServerError = HTTPStatusCode(500)

    /// A 501 status code, which indicates that the server does not support the functionality required to fulfill the
    /// request.
    public static let unimplemented = HTTPStatusCode(501)

    /// A 502 status code, which indicates that the server, while acting as a gateway or proxy, received an invalid
    /// response from an inbound server it accessed while attempting to fulfill the request.
    public static let badGateway = HTTPStatusCode(502)

    /// A 503 status code, which indicates that the server is currently unable to handle the request due to a temporary
    /// overload or scheduled maintenance, which will likely be alleviated after some delay.
    public static let serviceUnavailable = HTTPStatusCode(503)

    /// A 504 status code, which indicates that the server, while acting as a gateway or proxy, did not receive a timely
    /// response from an upstream server it needed to access in order to complete the request.
    public static let gatewayTimeout = HTTPStatusCode(504)

    /// A 505 status code, which indicates that the server does not support, or refuses to support, the major version of
    /// HTTP that was used in the request message.
    public static let httpVersionNotSupported = HTTPStatusCode(505)
}


extension HTTPURLResponse {
    /// Returns the HTTP URL response’s HTTP status code.
    public var httpStatusCode: HTTPStatusCode {
        return HTTPStatusCode(statusCode)
    }
}
