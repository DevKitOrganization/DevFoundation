//
//  LiveQueryResultsProducerTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 10/24/2025.
//

import Foundation
import Testing

@testable import DevFoundation

struct LiveQueryResultsProducerTests {
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
        // set up the test by creating a results producer
        let producer = TestResultsProducer()

        // exercise the test by canonicalizing the query fragment
        let result = producer.canonicalQueryFragment(from: input)

        // expect the result matches the expected canonical form
        #expect(result == expected)
    }


    struct TestResultsProducer: LiveQueryResultsProducer {
        var schedulingStrategy: LiveQuerySchedulingStrategy {
            .passthrough
        }


        func results(forQueryFragment queryFragment: String) async throws -> [String] {
            []
        }
    }
}
