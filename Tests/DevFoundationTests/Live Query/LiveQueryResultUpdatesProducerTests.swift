//
//  LiveQueryResultUpdatesProducerTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 11/24/2026.
//

import Foundation
import Testing

@testable import DevFoundation

struct LiveQueryResultUpdatesProducerTests {
    @Test(
        arguments: [
            ("hello", "hello"),
            ("  hello  ", "hello"),
            ("hello world", "hello world"),
            ("  hello   world  ", "hello world"),
            ("hello\nworld", "hello world"),
            ("hello\tworld", "hello world"),
            ("  hello  \n  world  \t  test  ", "hello world test"),
            ("", nil),
            ("   ", nil),
            ("\n\t", nil),
            ("  \n  \t  ", nil),
        ]
    )
    func canonicalQueryFragment(input: String, expected: String?) {
        // set up the test by creating a result updates producer
        let producer = TestResultUpdatesProducer()

        // exercise the test by canonicalizing the query fragment
        let result = producer.canonicalQueryFragment(from: input)

        // expect the result matches the expected canonical form
        #expect(result == expected)
    }


    struct TestResultUpdatesProducer: LiveQueryResultUpdatesProducer {
        var schedulingStrategy: LiveQuerySchedulingStrategy {
            .passthrough
        }


        func resultUpdates(forQueryFragment queryFragment: String) -> AsyncThrowingStream<[String], any Error> {
            AsyncThrowingStream { $0.finish() }
        }
    }
}
