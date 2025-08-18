//
//  Response.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/17/25.
//

import Foundation

extension SimulatedURLRequestLoader {
    public struct Response: Sendable {
        struct Success: Hashable, Sendable {
            let statusCode: HTTPStatusCode
            let headerItems: Set<HTTPHeaderItem>
            let body: Data
        }


        var result: Result<Success, any Error>
        var delay: Duration


        public init(
            statusCode: HTTPStatusCode,
            headerItems: Set<HTTPHeaderItem>,
            body: Data,
            delay: Duration
        ) {
            self.result = .success(.init(statusCode: statusCode, headerItems: headerItems, body: body))
            self.delay = delay
        }


        public init(error: any Error, delay: Duration) {
            self.result = .failure(error)
            self.delay = delay
        }


        func result(for requestComponents: RequestComponents) -> Result<(Data, URLResponse), any Error>? {
            do {
                let success = try result.get()

                guard
                    let httpURLResponse = HTTPURLResponse(
                        url: requestComponents.url,
                        statusCode: success.statusCode.rawValue,
                        httpVersion: nil,
                        headerFields: Dictionary(
                            success.headerItems.map { ($0.field.rawValue, $0.value) },
                            uniquingKeysWith: { $1 }
                        )
                    )
                else {
                    return nil
                }

                return .success((success.body, httpURLResponse))
            } catch {
                return .failure(error)
            }
        }
    }
}
