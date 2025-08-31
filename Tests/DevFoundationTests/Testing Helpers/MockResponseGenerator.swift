//
//  MockResponseGenerator.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/31/25.
//

import DevFoundation
import DevTesting
import Foundation

final class MockResponseGenerator: SimulatedURLRequestLoader.ResponseGenerator {
    nonisolated(unsafe) var responsePrologue: (() async -> Void)?

    // swift-format-ignore
    nonisolated(unsafe) var responseStub: Stub<
        SimulatedURLRequestLoader.RequestComponents,
        (Result<(Data, URLResponse), any Error>, delay: Duration)?
    >!


    func response(
        for requestComponents: SimulatedURLRequestLoader.RequestComponents
    ) async -> (Result<(Data, URLResponse), any Error>, delay: Duration)? {
        await responsePrologue?()
        return responseStub(requestComponents)
    }
}
