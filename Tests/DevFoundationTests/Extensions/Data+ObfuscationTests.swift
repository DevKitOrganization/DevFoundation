//
//  Data+ObfuscationTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 4/29/25.
//

import DevFoundation
@testable import enum DevFoundation.DataDeobfuscationError
@testable import enum DevFoundation.DataObfuscationError
import DevTesting
import Foundation
import Testing


struct Data_ObfuscationTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func obfuscateRoundTripSucceeds() throws {
        let message = randomData(count: 512)
        let key = randomData(count: 32)

        let obfuscatedMessage = try message.obfuscated(
            withKey: key,
            keySizeType: Int8.self,
            messageSizeType: Int16.self
        )

        #expect(!obfuscatedMessage.contains(message))
        #expect(obfuscatedMessage.contains(key))

        let deobfuscatedMessage = try obfuscatedMessage.deobfuscated(
            keySizeType: Int8.self,
            messageSizeType: Int16.self
        )

        #expect(deobfuscatedMessage == message)
    }


    @Test
    mutating func obfuscateFailsWhenMessageSizeIsTooSmall() throws {
        #expect(throws: DataObfuscationError.messageSizeExceedsMaximum) {
            _ = try randomData(count: 256).obfuscated(
                withKey: randomData(count: 32),
                keySizeType: UInt8.self,
                messageSizeType: UInt8.self
            )
        }
    }


    @Test
    mutating func obfuscateFailsWhenKeySizeIsTooSmall() throws {
        #expect(throws: DataObfuscationError.keySizeExceedsMaximum) {
            _ = try randomData(count: 16).obfuscated(
                withKey: randomData(count: 256),
                keySizeType: UInt8.self,
                messageSizeType: Int8.self
            )
        }
    }


    @Test
    mutating func deobfuscateFailsWhenMessageSizeIsTooSmall() throws {
        let obfuscatedMessage = try randomData(count: 128).obfuscated(
            withKey: randomData(count: 32),
            keySizeType: UInt8.self,
            messageSizeType: UInt8.self
        )

        #expect(throws: DataDeobfuscationError.invalidMessage) {
            _ = try obfuscatedMessage.deobfuscated(
                keySizeType: UInt8.self,
                messageSizeType: UInt32.self
            )
        }
    }


    @Test
    mutating func deobfuscateFailsWhenKeySizeIsTooSmall() throws {
        let obfuscatedMessage = try randomData(count: 128).obfuscated(
            withKey: randomData(count: 32),
            keySizeType: UInt8.self,
            messageSizeType: UInt8.self
        )

        #expect(throws: DataDeobfuscationError.invalidKey) {
            _ = try obfuscatedMessage.deobfuscated(
                keySizeType: UInt16.self,
                messageSizeType: UInt8.self
            )
        }
    }


    @Test
    mutating func deobfuscateFailsWhenDataIsTooShort() throws {
        #expect(throws: DataDeobfuscationError.invalidMessage) {
            _ = try randomData(count: 1).deobfuscated(
                keySizeType: UInt16.self,
                messageSizeType: UInt16.self
            )
        }
    }


    @Test
    mutating func deobfuscateFailsWhenKeyIsZero() throws {
        let message = randomData(count: 16)
        let data = message.count.bigEndianData + message + UInt8.zero.bigEndianData

        #expect(throws: DataDeobfuscationError.invalidKey) {
            _ = try data.deobfuscated(
                keySizeType: UInt8.self,
                messageSizeType: Int.self
            )
        }
    }
}
