//
//  DispatchQueue+StandardTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 4/1/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct DispatchQueue_StandardTests {
    @Test
    func utilityQueueHasCorrectProperties() {
        let queue = DispatchQueue.utility
        #expect(queue.label == "devfoundation.utility")
        #expect(queue.qos == .utility)
    }
}
