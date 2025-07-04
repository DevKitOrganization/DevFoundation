//
//  BusEvent.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/30/25.
//

import Foundation

/// An event that can be posted to an event bus.
///
/// Types that conform to `BusEvent` have no requirements other than being `Sendable`. They are nearly always structs
/// that contain data about the event being posted.
///
/// `BusEvent`s that are also `Identifiable` enable special handling by ``BusEventObserver``s and
/// ``ContextualBusEventObserver``, in particular.
public protocol BusEvent: Sendable {}
