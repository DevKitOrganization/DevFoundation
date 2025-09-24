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

        try await confirmation("task is executed", expectedCount: 2) { (didExecute) in
            try await confirmation("emits isExecuting observation events", expectedCount: 2) { (didObserve) in
                withObservationTracking {
                    // Is executing should initially be false
                    #expect(!group.isExecuting)
                } onChange: {
                    // It should change to true
                    didObserve()
                    withObservationTracking {
                        #expect(group.isExecuting)
                    } onChange: {
                        // It should change back to false
                        didObserve()
                        #expect(!group.isExecuting)
                    }
                }

                // Start two tasks
                let task1 = group.addTask {
                    // While the task is running, isExecuting should be true
                    didExecute()
                    #expect(group.isExecuting)
                    try? await Task.sleep(for: .milliseconds(250))

                }

                let task2 = group.addTask {
                    // While the task is running, isExecuting should be true
                    didExecute()
                    #expect(group.isExecuting)
                    try await Task.sleep(for: .milliseconds(250))
                }

                // Wait for the tasks to finish
                let _ = (await task1.value, try await task2.value)

                // When the tasks are finished, isExecuting should be false
                #expect(!group.isExecuting)
            }
        }
    }
}
