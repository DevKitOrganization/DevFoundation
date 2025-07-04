//
//  JSONBodyWebServiceRequest.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/18/25.
//

import Foundation

/// A web service request with a JSON body.
///
/// Types that conform to `JSONBodyWebServiceRequest`s provide a JSON body as an encodable type.
public protocol JSONBodyWebServiceRequest: WebServiceRequest {
    /// The type of the request’s body expressed as an encodable type.
    associatedtype JSONBody: Encodable

    /// The JSON encoder to use when creating the body’s data.
    ///
    /// This defaults to `JSONEncoder()`, but requests with specific needs can customize it.
    var jsonEncoder: JSONEncoder { get }

    /// The request’s body expressed as an encodable type.
    var jsonBody: JSONBody { get }
}


extension JSONBodyWebServiceRequest {
    /// An HTTP body whose content type is ``MediaType/json`` and whose data is an encoded version of the request’s JSON
    /// body.
    public var httpBody: HTTPBody? {
        get throws {
            return HTTPBody(contentType: .json, data: try jsonEncoder.encode(jsonBody))
        }
    }


    public var jsonEncoder: JSONEncoder {
        return JSONEncoder()
    }
}
