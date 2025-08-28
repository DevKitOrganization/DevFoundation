//
//  ResponseGenerator.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/17/25.
//

import Foundation

extension SimulatedURLRequestLoader {
    public protocol ResponseGenerator: Sendable {
        func response(
            for requestComponents: RequestComponents
        ) async -> (Result<(Data, URLResponse), any Error>, delay: Duration)?
    }
}


extension SimulatedURLRequestLoader {
    struct FixedResponseGenerator: ResponseGenerator {
        let result: Result<SuccessResponseTemplate, any Error>
        let delay: Duration


        func response(
            for requestComponents: RequestComponents
        ) async -> (Result<(Data, URLResponse), any Error>, delay: Duration)? {
            do {
                let template = try result.get()
                guard let successResponse = template.response(for: requestComponents) else {
                    return nil
                }

                return (.success(successResponse), delay: delay)
            } catch {
                return (.failure(error), delay: delay)
            }
        }
    }
}


extension SimulatedURLRequestLoader {
    @discardableResult
    public func respond(
        with error: any Error,
        delay: Duration = .zero,
        maxResponses: Int? = 1,
        when requestConditions: [any RequestCondition]
    ) -> some Responder {
        let responder = Responder(
            requestConditions: requestConditions,
            responseGenerator: FixedResponseGenerator(
                result: .failure(error),
                delay: delay
            ),
            maxResponses: maxResponses
        )
        add(responder)
        return responder
    }


    @discardableResult
    public func respond(
        with statusCode: HTTPStatusCode,
        headerItems: Set<HTTPHeaderItem> = [],
        body: Data,
        delay: Duration = .zero,
        maxResponses: Int? = 1,
        when requestConditions: [any RequestCondition]
    ) -> some Responder {
        let responder = Responder(
            requestConditions: requestConditions,
            responseGenerator: FixedResponseGenerator(
                result: .success(
                    SuccessResponseTemplate(
                        statusCode: statusCode,
                        headerItems: headerItems,
                        body: body
                    )
                ),
                delay: delay
            ),
            maxResponses: maxResponses
        )
        add(responder)
        return responder
    }


    @discardableResult
    public func respond(
        with statusCode: HTTPStatusCode,
        headerItems: Set<HTTPHeaderItem> = [],
        body: String,
        encoding: String.Encoding = .utf8,
        delay: Duration = .zero,
        maxResponses: Int? = 1,
        when requestConditions: [any RequestCondition]
    ) -> some Responder {
        let responder = Responder(
            requestConditions: requestConditions,
            responseGenerator: FixedResponseGenerator(
                result: .success(
                    SuccessResponseTemplate(
                        statusCode: statusCode,
                        headerItems: headerItems,
                        body: body.data(using: encoding)!
                    )
                ),
                delay: delay
            ),
            maxResponses: maxResponses
        )
        add(responder)
        return responder
    }


    @discardableResult
    public func respond<Body>(
        with statusCode: HTTPStatusCode,
        headerItems: Set<HTTPHeaderItem> = [],
        body: Body,
        encoder: any TopLevelEncoder<Data> = JSONEncoder(),
        delay: Duration = .zero,
        maxResponses: Int? = 1,
        when requestConditions: [any RequestCondition]
    ) -> some Responder
    where Body: Encodable {
        let responder = Responder(
            requestConditions: requestConditions,
            responseGenerator: FixedResponseGenerator(
                result: .success(
                    SuccessResponseTemplate(
                        statusCode: statusCode,
                        headerItems: headerItems,
                        body: try! encoder.encode(body)
                    )
                ),
                delay: delay
            ),
            maxResponses: maxResponses
        )
        add(responder)
        return responder
    }
}
