//
//  MockBaseURLConfiguration.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/18/25.
//

import DevFoundation
import DevTesting
import Foundation

final class MockBaseURLConfiguration: BaseURLConfiguring {
    nonisolated(unsafe) var urlStub: Stub<Int, URL>!


    func url(for baseURL: Int) -> URL {
        return urlStub(baseURL)
    }
}
