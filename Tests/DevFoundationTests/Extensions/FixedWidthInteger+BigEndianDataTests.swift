//
//  FixedWidthInteger+BigEndianDataTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 4/28/25.
//

import DevTesting
import Foundation
import Testing

@testable import DevFoundation

struct FixedWidthInteger_BigEndianDataTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    func byteWidthIsCorrectForStandardFixedWidthIntegerTypes() {
        #expect(Int.byteWidth == Int.bitWidth / 8)
        #expect(Int8.byteWidth == 1)
        #expect(Int16.byteWidth == 2)
        #expect(Int32.byteWidth == 4)
        #expect(Int64.byteWidth == 8)

        #expect(UInt.byteWidth == UInt.bitWidth / 8)
        #expect(UInt8.byteWidth == 1)
        #expect(UInt16.byteWidth == 2)
        #expect(UInt32.byteWidth == 4)
        #expect(UInt64.byteWidth == 8)
    }


    @Test
    func bigEndianConversion() {
        let int: Int = 0x0123_4567_89AB_CDEF
        let intBigEndianData = Data([0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF])
        #expect(int == Int(bigEndianData: intBigEndianData))
        #expect(int.bigEndianData == intBigEndianData)

        let int8: Int8 = 0x46
        let int8BigEndianData = Data([0x46])
        #expect(int8 == Int8(bigEndianData: int8BigEndianData))
        #expect(int8.bigEndianData == int8BigEndianData)

        let int16: Int16 = 0x631F
        let int16BigEndianData = Data([0x63, 0x1F])
        #expect(int16 == Int16(bigEndianData: int16BigEndianData))
        #expect(int16.bigEndianData == int16BigEndianData)

        let int32: Int32 = 0x1234_5678
        let int32BigEndianData = Data([0x12, 0x34, 0x56, 0x78])
        #expect(int32 == Int32(bigEndianData: int32BigEndianData))
        #expect(int32.bigEndianData == int32BigEndianData)

        let int64: Int64 = 0x0123_4567_89AB_CDEF
        let int64BigEndianData = Data([0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF])
        #expect(int64 == Int64(bigEndianData: int64BigEndianData))
        #expect(int64.bigEndianData == int64BigEndianData)

        let uint: UInt = 0xF0D1_C2B3_A495_8677
        let uintBigEndianData = Data([0xF0, 0xD1, 0xC2, 0xB3, 0xA4, 0x95, 0x86, 0x77])
        #expect(uint == UInt(bigEndianData: uintBigEndianData))
        #expect(uint.bigEndianData == uintBigEndianData)

        let uint8: UInt8 = 0xDF
        let uint8BigEndianData = Data([0xDF])
        #expect(uint8 == UInt8(bigEndianData: uint8BigEndianData))
        #expect(uint8.bigEndianData == uint8BigEndianData)

        let uint16: UInt16 = 0xABCD
        let uint16BigEndianData = Data([0xAB, 0xCD])
        #expect(uint16 == UInt16(bigEndianData: uint16BigEndianData))
        #expect(uint16.bigEndianData == uint16BigEndianData)

        let uint32: UInt32 = 0xFEDC_BA98
        let uint32BigEndianData = Data([0xFE, 0xDC, 0xBA, 0x98])
        #expect(uint32 == UInt32(bigEndianData: uint32BigEndianData))
        #expect(uint32.bigEndianData == uint32BigEndianData)

        let uint64: UInt64 = 0xF0D1_C2B3_A495_8677
        let uint64BigEndianData = Data([0xF0, 0xD1, 0xC2, 0xB3, 0xA4, 0x95, 0x86, 0x77])
        #expect(uint64 == UInt64(bigEndianData: uint64BigEndianData))
        #expect(uint64.bigEndianData == uint64BigEndianData)
    }


    @Test
    mutating func initWithBigEndianDataDoesNotFailWithDataSlice() {
        let data = Data([0x0F, 0x1D, 0x2C, 0x3B, 0x4A, 0x59, 0x68, 0x77, 0x86, 0x95])
        #expect(Int(bigEndianData: data[1 ..< 9]) == 0x1D2C_3B4A_5968_7786)
    }


    @Test
    mutating func bigEndianConversionReturnsNilWhenDataIsIncorrectSize() {
        #expect(Int(bigEndianData: randomData(count: random(Int.self, in: 9 ... 16))) == nil)
        #expect(Int8(bigEndianData: randomData(count: random(Int.self, in: 2 ... 8))) == nil)
        #expect(Int16(bigEndianData: randomData(count: random(Int.self, in: 3 ... 8))) == nil)
        #expect(Int32(bigEndianData: randomData(count: random(Int.self, in: 1 ... 3))) == nil)
        #expect(Int64(bigEndianData: randomData(count: random(Int.self, in: 1 ... 7))) == nil)

        #expect(UInt(bigEndianData: randomData(count: random(Int.self, in: 9 ... 16))) == nil)
        #expect(UInt8(bigEndianData: randomData(count: random(Int.self, in: 2 ... 8))) == nil)
        #expect(UInt16(bigEndianData: randomData(count: random(Int.self, in: 3 ... 8))) == nil)
        #expect(UInt32(bigEndianData: randomData(count: random(Int.self, in: 1 ... 3))) == nil)
        #expect(UInt64(bigEndianData: randomData(count: random(Int.self, in: 1 ... 7))) == nil)
    }
}
