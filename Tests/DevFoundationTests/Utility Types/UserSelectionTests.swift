//
//  UserSelectionTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 10/22/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct UserSelectionTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()

    @Test
    mutating func valueReturnsCorrectValueBasedOnSelection() {
        // set up the test by creating values
        let defaultValue = randomAlphanumericString()
        let selectedValue = randomAlphanumericString()
        var userSelection = UserSelection(defaultValue: defaultValue)

        // expect defaultValue is returned when selectedValue is nil
        #expect(userSelection.value == defaultValue)

        // exercise the test by setting selectedValue
        userSelection.selectedValue = selectedValue

        // expect selectedValue is returned when it is non-nil
        #expect(userSelection.value == selectedValue)

        // exercise the test by resetting selectedValue to nil
        userSelection.selectedValue = nil

        // expect defaultValue is returned when selectedValue is reset to nil
        #expect(userSelection.value == defaultValue)
    }
}
