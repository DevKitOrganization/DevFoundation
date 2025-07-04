//
//  MockBusEvents.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 4/4/25.
//

import DevFoundation
import Foundation

struct MockBusEvent: BusEvent, Hashable {
    let string: String
}


struct MockIdentifiableBusEvent: BusEvent, Hashable, Identifiable {
    let id: Int
    let string: String
}
