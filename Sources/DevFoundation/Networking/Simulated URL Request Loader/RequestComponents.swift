//
//  RequestComponents.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/17/25.
//

import Foundation

extension SimulatedURLRequestLoader {
    public struct RequestComponents: Hashable, Sendable {
        let headerItems: Set<HTTPHeaderItem>
        let httpMethod: HTTPMethod
        let url: URL
        let urlComponents: URLComponents
        let urlRequest: URLRequest


        init?(urlRequest: URLRequest) {
            guard
                let url = urlRequest.url?.absoluteURL,
                let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
                let httpMethod = urlRequest.httpMethod.flatMap(HTTPMethod.init)
            else {
                return nil
            }

            self.headerItems = Set(urlRequest.httpHeaderItems)
            self.httpMethod = httpMethod
            self.url = url
            self.urlComponents = urlComponents
            self.urlRequest = urlRequest
        }


        var body: Data {
            urlRequest.httpBody ?? Data()
        }
    }
}
