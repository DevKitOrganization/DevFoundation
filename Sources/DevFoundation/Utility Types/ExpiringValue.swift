//
//  ExpiringValue.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 6/16/25.
//

import Foundation


/// A value that can expire after its lifetime is complete.
///
/// This type is useful for implementing time-based caches. 
public struct ExpiringValue<Value> {
    /// The value.
    public let value: Value
    
    /// The range of dates encompassing the value’s lifetime.
    ///
    /// The value is expired for any dates outside of this range.
    public let lifetimeRange: ClosedRange<Date>
    
    /// Whether the value has been manually expired by calling ``expire()``.
    private var isManuallyExpired: Bool = false

    
    /// Creates a new expiring value with the specified value and lifetime range.
    ///
    /// - Parameters:
    ///   - value: The value.
    ///   - lifetimeRange: The range of dates encompassing teh value’s lifetime.
    public init(_ value: Value, lifetimeRange: ClosedRange<Date>) {
        self.value = value
        self.lifetimeRange = lifetimeRange
    }


    /// Creates a new expiring value with the specified value and lifetime duration.
    ///
    /// The value’s lifetime starts now and ends `lifetimeDuration` seconds in the future.
    ///
    /// - Parameters:
    ///   - value: The value.
    ///   - lifetimeDuration: The length of the value’s lifetime.
    public init(_ value: Value, lifetimeDuration: TimeInterval) {
        let now = DateProviders.current.now
        self.value = value
        self.lifetimeRange = now ... (now + lifetimeDuration)
    }

    
    /// Manually expires the value.
    ///
    /// Use this function mark a value as expired, regardless of its lifetime range.
    public mutating func expire() {
        isManuallyExpired = true
    }

    
    /// Whether the value is expired now.
    ///
    /// See ``isExpired(at:)`` for details about how expiration is computed.
    public var isExpired: Bool {
        return isExpired(at: DateProviders.current.now)
    }

    
    /// Whether the value is expired at a specified date.
    ///
    /// This function returns true if the value was manually expired or `date` is outside the lifetime range of the
    /// value.
    ///
    /// - Parameter date: The date for which to determine whether the value is expired.
    public func isExpired(at date: Date) -> Bool {
        return isManuallyExpired || !lifetimeRange.contains(date)
    }
}


extension ExpiringValue: Decodable where Value: Decodable { }
extension ExpiringValue: Encodable where Value: Encodable { }
extension ExpiringValue: Equatable where Value: Equatable { }
extension ExpiringValue: Hashable where Value: Hashable { }
extension ExpiringValue: Sendable where Value: Sendable { }
