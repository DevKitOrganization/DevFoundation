//
//  ExecutionGroupTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 4/12/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct ExecutionGroupTests {
    @Test
    func tasksUpdateIsExecuting() async throws {
        let group = ExecutionGroup()
        #expect(!group.isExecuting)

        let observationTask = Task {
            var observedValues: [Bool] = []
            for await observation in Observations({ group.isExecuting }) {
                observedValues.append(observation)

                print(observedValues)
                if !observation {
                    break
                }
            }

            #expect((1 ... 2).contains(observedValues.count { $0 == true }))
            #expect(observedValues.count { $0 == false } == 1)
        }

        try await confirmation("task is executed", expectedCount: 2) { (didExecute) in
            // Start two tasks
            let task1 = group.addTask {
                // While the task is running, isExecuting should be true
                didExecute()
                #expect(group.isExecuting)
                try? await Task.sleep(for: .milliseconds(100))

            }

            let task2 = group.addTask {
                // While the task is running, isExecuting should be true
                didExecute()
                #expect(group.isExecuting)
                try await Task.sleep(for: .milliseconds(200))
            }

            // Wait for the tasks to finish
            let _ = (await task1.value, try await task2.value)

            // When the tasks are finished, isExecuting should be false
            #expect(!group.isExecuting)
        }

        await observationTask.value
    }
}
