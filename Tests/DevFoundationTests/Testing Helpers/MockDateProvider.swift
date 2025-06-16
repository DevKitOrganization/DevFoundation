//
//  MockDateProvider.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 6/16/25.
//

import DevFoundation
import DevTesting
import Foundation


final class MockDateProvider: DateProvider {
    nonisolated(unsafe)
    var stub_now: Stub<Void, Date>!


    convenience init(now: Date) {
        self.init()
        self.stub_now = Stub(defaultReturnValue: now)
    }


    var now: Date {
        stub_now()
    }
}
