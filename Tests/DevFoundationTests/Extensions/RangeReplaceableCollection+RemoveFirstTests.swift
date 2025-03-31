//
//  RangeReplaceableCollection+RemoveFirstTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 4/5/25.
//

@testable import DevFoundation
import DevTesting
import Foundation
import Testing


struct RangeReplaceableCollection_RemoveFirstTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func rethrowsErrorWhenPredicateThrows() {
        // Create an array of random elements
        var array = Array(count: random(Int.self, in: 3 ... 5)) { randomBool() }
        let copy = array

        // Try to remove an element with an unsatisfiable predicate and expect removeFirst to return nil
        // and for the array to not change
        let error = randomError()

        #expect(throws: error) {
            _ = try array.removeFirst { _ in throw error }
        }
        #expect(array == copy)
    }


    @Test
    mutating func removeFirstReturnsNilIfNoElementsAreRemoved() {
        // Create an array of random elements
        var array = Array(count: random(Int.self, in: 3 ... 5)) { randomAlphanumericString() }
        let copy = array

        // Try to remove an element with an unsatisfiable predicate and expect removeFirst to return nil
        // and for the array to not change
        #expect(array.removeFirst { _ in false } == nil)
        #expect(array == copy)
    }


    @Test
    mutating func removeFirstReturnsTheElementThatWasRemoved() {
        // Create an array with random elements
        var array = Array(count: random(Int.self, in: 3 ... 5)) { randomAlphanumericString() }

        // Duplicate elements in the array an arbitrary number of times
        for _ in 0 ..< random(Int.self, in: 1 ... 3) {
            array += array
        }

        // Shuffle the elements
        array.shuffle(using: &randomNumberGenerator)

        // Choose a random index to remove
        let index = array.firstIndex(of: randomElement(in: array)!)!
        var copy = array
        let removedElement = copy.remove(at: index)

        // Remove the first of those, and expect the removal to have worked
        #expect(array.removeFirst { $0 == removedElement } == removedElement)
        #expect(array == copy)
    }
}
