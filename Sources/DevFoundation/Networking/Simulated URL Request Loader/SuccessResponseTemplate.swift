//
//  Response.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/17/25.
//

import Foundation

extension SimulatedURLRequestLoader {
    public struct SuccessResponseTemplate: Sendable {
        public let statusCode: HTTPStatusCode
        public let headerItems: Set<HTTPHeaderItem>
        public let body: Data


        public init(
            statusCode: HTTPStatusCode,
            headerItems: Set<HTTPHeaderItem>,
            body: Data
        ) {
            self.statusCode = statusCode
            self.headerItems = headerItems
            self.body = body
        }


        public func response(for requestComponents: RequestComponents) -> (Data, URLResponse)? {
            guard
                let httpURLResponse = HTTPURLResponse(
                    url: requestComponents.url,
                    statusCode: statusCode.rawValue,
                    httpVersion: nil,
                    headerFields: Dictionary(
                        headerItems.map { ($0.field.rawValue, $0.value) },
                        uniquingKeysWith: { $1 }
                    )
                )
            else {
                return nil
            }

            return (body, httpURLResponse)
        }
    }
}
