//
//  MockLiveQueryResultsProducer.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 10/24/2025.
//

import DevTesting
import Foundation

@testable import DevFoundation


final class MockLiveQueryResultsProducer<Results>: LiveQueryResultsProducer where Results: Sendable {
    nonisolated(unsafe) var schedulingStrategyStub: Stub<Void, LiveQuerySchedulingStrategy>!
    nonisolated(unsafe) var canonicalQueryFragmentStub: Stub<String, String?>!
    nonisolated(unsafe) var resultsStub: ThrowingStub<String, Results, any Error>!
    nonisolated(unsafe) var resultsEpilogue: (() async throws -> Void)?


    var schedulingStrategy: LiveQuerySchedulingStrategy {
        schedulingStrategyStub()
    }


    func canonicalQueryFragment(from queryFragment: String) -> String? {
        canonicalQueryFragmentStub(queryFragment)
    }


    func results(forQueryFragment queryFragment: String) async throws -> Results {
        defer {
            if let epilogue = resultsEpilogue {
                Task { try? await epilogue() }
            }
        }
        return try resultsStub(queryFragment)
    }
}
