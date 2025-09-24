//
//  ObservableReferenceTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 9/24/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct ObservableReferenceTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func observability() async {
        let initialValue = randomInt(in: .min ... .max)
        let changes = Array(count: 3) { randomInt(in: .min ... .max) }
        let expectedObservedValues = [initialValue] + changes

        let reference = ObservableReference(initialValue)

        let observationTask = Task {
            var observedValues: [Int] = []
            for await observation in Observations({ reference.value }) {
                observedValues.append(observation)

                if observedValues.count == expectedObservedValues.count {
                    break
                }
            }

            #expect(observedValues == expectedObservedValues)
        }

        Task {
            for value in changes {
                try? await Task.sleep(for: .milliseconds(100))
                reference.value = value
            }
        }

        await observationTask.value
    }
}
