//
//  MockLiveQueryResultUpdatesProducer.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 11/24/2026.
//

import DevTesting
import Foundation

@testable import DevFoundation

final class MockLiveQueryResultUpdatesProducer<Results, ResultUpdates>: LiveQueryResultUpdatesProducer
where Results: Sendable, ResultUpdates: AsyncSequence<Results, any Error> & Sendable {
    nonisolated(unsafe) var schedulingStrategyStub = Stub<Void, LiveQuerySchedulingStrategy>()
    nonisolated(unsafe) var canonicalQueryFragmentStub = Stub<String, String?>()
    nonisolated(unsafe) var resultUpdatesStub: Stub<String, ResultUpdates>!


    var schedulingStrategy: LiveQuerySchedulingStrategy {
        schedulingStrategyStub()
    }


    func canonicalQueryFragment(from queryFragment: String) -> String? {
        canonicalQueryFragmentStub(queryFragment)
    }


    func resultUpdates(forQueryFragment queryFragment: String) -> ResultUpdates {
        resultUpdatesStub(queryFragment)
    }
}
