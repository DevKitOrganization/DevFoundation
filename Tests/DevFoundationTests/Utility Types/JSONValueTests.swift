//
//  JSONValueTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/20/25.
//

import DevFoundation
@testable import struct DevFoundation.JSONCodingKey
import DevTesting
import Foundation
import Testing


struct JSONValueTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    // MARK: - Codable

    @Test
    func codableArray() throws {
        let array: JSONValue = .array(
            [
                .array([.number(100 as UInt), .number(-100), .number(Float64.pi)]),
                .boolean(true),
                .ifPresent(nil as String?),
                .ifPresent(.ifPresent(.ifPresent(12345))),
                .number(123_456_789 as UInt),
                .number(-123_456_789),
                .number(2.718281828),
                .object(
                    [
                        "key1": .null,
                        "key2": .ifPresent(.ifPresent(.number(0))),
                        "key3": .ifPresent(nil as Bool?)
                    ]
                ),
                .null,
                .string("string"),
            ]
        )

        let jsonData = try JSONEncoder().encode(array)
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData)

        let expectedJSONObject: [Any?] = [
            [100, -100, Float64.pi],
            true,
            12345,
            123_456_789,
            -123_456_789,
            2.718281828,
            ["key1": nil, "key2": 0],
            nil,
            "string",
        ]

        #expect(jsonObject as? NSArray == expectedJSONObject as NSArray)

        let decodedArray = try JSONDecoder().decode(JSONValue.self, from: jsonData)
        #expect(array == decodedArray)
    }


    @Test
    func codableObject() throws {
        let object: JSONValue = .object(
            [
                "array": .array(
                    [
                        .number(100 as UInt),
                        .number(-100),
                        .ifPresent(.ifPresent(.number(Float64.pi))),
                        .ifPresent(nil as Int?)
                    ]
                ),
                "bool": .boolean(true),
                "notPresent": .ifPresent(nil as String?),
                "present": .ifPresent(.ifPresent(.ifPresent(12345))),
                "number1": .number(UInt.max),
                "number2": .number(-123_456_789),
                "number3": .number(2.718281828),
                "object": .object(
                    [
                        "key1": .null,
                        "key2": .ifPresent(.number(0)),
                        "key3": .ifPresent(nil as Bool?)
                    ]
                ),
                "null": .null,
                "string": .string("string"),
            ]
        )

        let jsonData = try JSONEncoder().encode(object)
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData)

        let expectedJSONObject: [String: Any?] = [
            "array": [100, -100, Float64.pi],
            "bool": true,
            "present": 12345,
            "number1": UInt.max,
            "number2": -123_456_789,
            "number3": 2.718281828,
            "object": ["key1": nil, "key2": 0],
            "null": nil,
            "string": "string",
        ]

        #expect(jsonObject as? NSDictionary == expectedJSONObject as NSDictionary)

        let decodedObject = try JSONDecoder().decode(JSONValue.self, from: jsonData)
        #expect(object == decodedObject)
    }


    @Test
    func invalidSingleValueContainer() throws {
        // We use a property list because it can encode a data type that is inexpressible with JSON (dates)
        let plistData = try PropertyListEncoder().encode([Date()])

        #expect(throws: DecodingError.self) {
            try PropertyListDecoder().decode(JSONValue.self, from: plistData)
        }
    }


    @Test
    func encodeIfPresent() {
        #expect(throws: EncodingError.self) {
            try JSONEncoder().encode(JSONValue.ifPresent(0))
        }
    }


    @Test
    mutating func jsonCodingKey() throws {
        let stringValue = randomAlphanumericString()
        let key = JSONCodingKey(stringValue: stringValue)
        #expect(key.stringValue == stringValue)
        #expect(key.intValue == nil)

        #expect(JSONCodingKey(intValue: random(Int.self, in: .min ... .max)) == nil)
    }


    // MARK: - Hashable

    @Test
    func hashableForArrays() {
        let array: JSONValue = [nil, false, 1, "two", .ifPresent(.ifPresent(.number(Float64.pi)))]
        let equal = array
        let unequal: JSONValue = [.ifPresent(.ifPresent(.number(Float64.pi))), "two", 1, false, nil, 0]

        #expect(array == equal)
        #expect(equal == array)
        #expect(array.hashValue == equal.hashValue)

        #expect(array != unequal)
        #expect(unequal != array)
    }


    @Test
    func hashableForBooleans() {
        let boolean: JSONValue = false
        let equal = boolean
        let unequal: JSONValue = true

        #expect(boolean == equal)
        #expect(equal == boolean)
        #expect(boolean.hashValue == equal.hashValue)

        #expect(boolean != unequal)
        #expect(unequal != boolean)
    }


    @Test
    func hashableForIfPresent() {
        let present: JSONValue = .ifPresent(42)
        let presentEqual = present
        let presentUnequal: JSONValue = .ifPresent(false)
        let notPresent: JSONValue = .ifPresent(nil as JSONValue?)

        #expect(present == presentEqual)
        #expect(presentEqual == present)
        #expect(present.hashValue == presentEqual.hashValue)

        #expect(notPresent == notPresent)
        #expect(notPresent.hashValue == notPresent.hashValue)

        #expect(present != presentUnequal)
        #expect(presentUnequal != present)

        #expect(present != notPresent)
        #expect(notPresent != present)

        #expect(42 == present)
        #expect(present == 42)
    }


    @Test
    func hashableForNulls() {
        #expect(JSONValue.null == .null)
        #expect(JSONValue.null.hashValue == JSONValue.null.hashValue)
    }


    @Test
    func hashableForNumbers() {
        let number: JSONValue = .number(12345)
        let equal: JSONValue = .number(12345.0)
        let unequal: JSONValue = .number(.unsignedInteger(123456))

        #expect(number == equal)
        #expect(equal == number)
        #expect(number.hashValue == equal.hashValue)

        #expect(number != unequal)
        #expect(unequal != number)
    }


    @Test
    func hashableForObjects() {
        let object: JSONValue = [
            "key1": nil,
            "key2": false,
            "key3": 1,
            "key4": "two",
            "key5": .ifPresent(.ifPresent(.number(Float64.pi)))
        ]
        let equal = object
        let unequal: JSONValue = [
            "key1": .ifPresent(.ifPresent(.number(Float64.pi))),
            "key2": "two",
            "key3": 1,
            "key4": false,
            "key5": nil,
            "key6": 0
        ]

        #expect(object == equal)
        #expect(equal == object)
        #expect(object.hashValue == equal.hashValue)

        #expect(object != unequal)
        #expect(unequal != object)
    }


    @Test
    func hashableForStrings() {
        let string: JSONValue = "spacely"
        let equal = string
        let unequal: JSONValue = "sprockets"

        #expect(string == equal)
        #expect(equal == string)
        #expect(string.hashValue == equal.hashValue)

        #expect(string != unequal)
        #expect(unequal != string)
    }


    @Test
    mutating func jsonValueNumberHashableWhenLHSIsFloatingPoint() {
        let float64 = random(Float64.self, in: 0 ... 100)
        let roundedFloat64 = float64.rounded(.towardZero)

        // Equal
        let floatingPoint = JSONValue.Number.floatingPoint(float64)
        let roundedFloatingPoint = JSONValue.Number.floatingPoint(roundedFloat64)
        let roundedInteger = JSONValue.Number.integer(Int64(roundedFloat64))
        let roundedUnsignedInteger = JSONValue.Number.unsignedInteger(UInt64(roundedFloat64))

        #expect(floatingPoint == floatingPoint)
        #expect(floatingPoint.hashValue == floatingPoint.hashValue)
        #expect(roundedFloatingPoint.hashValue == roundedInteger.hashValue)
        #expect(roundedFloatingPoint.hashValue == roundedUnsignedInteger.hashValue)

        // Not equal
        #expect(floatingPoint != .floatingPoint(float64 * 2))
        #expect(floatingPoint != roundedInteger)
        #expect(floatingPoint != roundedUnsignedInteger)
        #expect(floatingPoint != .integer(.min))
        #expect(floatingPoint != .integer(.max))
        #expect(floatingPoint != .unsignedInteger(.max))
    }


    @Test
    mutating func jsonValueNumberHashableWhenLHSIsInteger() {
        let nonNegativeInt64 = random(Int64.self, in: 0 ... 10_000)
        let negativeInt64 = random(Int64.self, in: -10_000 ..< 0)

        // Equal
        let integer = JSONValue.Number.integer(nonNegativeInt64)
        let negativeInteger = JSONValue.Number.integer(negativeInt64)
        let floatingPoint = JSONValue.Number.floatingPoint(Float64(nonNegativeInt64))
        let unsignedInteger = JSONValue.Number.unsignedInteger(UInt64(nonNegativeInt64))

        #expect(integer == integer)
        #expect(integer.hashValue == integer.hashValue)
        #expect(integer == floatingPoint)
        #expect(integer.hashValue == floatingPoint.hashValue)
        #expect(integer == unsignedInteger)
        #expect(integer.hashValue == unsignedInteger.hashValue)

        // Not equal
        #expect(negativeInteger != integer)
        #expect(negativeInteger != unsignedInteger)
        #expect(negativeInteger != .unsignedInteger(.max))
    }


    @Test
    mutating func jsonValueNumberHashableWhenLHSIsUnsignedInteger() {
        let uint64 = random(UInt64.self, in: 0 ..< 10_000)
        let unequalUInt64 = random(UInt64.self, in: 10_000 ... 100_000)

        // Equal
        let unsignedInteger = JSONValue.Number.unsignedInteger(UInt64(uint64))
        let unequalUnsignedInteger = JSONValue.Number.unsignedInteger(UInt64(unequalUInt64))

        let floatingPoint = JSONValue.Number.floatingPoint(Float64(uint64))
        let integer = JSONValue.Number.integer(Int64(uint64))

        #expect(unsignedInteger == unsignedInteger)
        #expect(unsignedInteger.hashValue == unsignedInteger.hashValue)
        #expect(unsignedInteger == floatingPoint)
        #expect(unsignedInteger.hashValue == floatingPoint.hashValue)
        #expect(unsignedInteger == integer)
        #expect(unsignedInteger.hashValue == integer.hashValue)

        // Not equal
        #expect(unequalUnsignedInteger != integer)
        #expect(unequalUnsignedInteger != unsignedInteger)
        #expect(unequalUnsignedInteger != .integer(.min))
    }


    // MARK: - Convenient Creation

    @Test
    mutating func ifPresentBool() {
        #expect(JSONValue.ifPresent(nil as Bool?) == .ifPresent(nil as JSONValue?))
        let value = randomBool()
        #expect(JSONValue.ifPresent(value) == .ifPresent(.boolean(value)))
    }


    @Test
    mutating func ifPresentFloatingPoint() {
        // Float32
        #expect(JSONValue.ifPresent(nil as Float32?) == .ifPresent(nil as JSONValue?))
        let float32 = random(Float32.self, in: -100 ... 100)
        #expect(JSONValue.ifPresent(float32) == .ifPresent(.number(float32)))

        // Float64
        #expect(JSONValue.ifPresent(nil as Float64?) == .ifPresent(nil as JSONValue?))
        let float64 = random(Float64.self, in: -100 ... 100)
        #expect(JSONValue.ifPresent(float64) == .ifPresent(.number(float64)))
    }


    @Test
    mutating func ifPresentSignedInteger() {
        // Int
        #expect(JSONValue.ifPresent(nil as Int?) == .ifPresent(nil as JSONValue?))
        let int = random(Int.self, in: .min ... .max)
        #expect(JSONValue.ifPresent(int) == .ifPresent(.number(int)))

        // Int8
        #expect(JSONValue.ifPresent(nil as Int8?) == .ifPresent(nil as JSONValue?))
        let int8 = random(Int8.self, in: .min ... .max)
        #expect(JSONValue.ifPresent(int8) == .ifPresent(.number(int8)))

        // Int16
        #expect(JSONValue.ifPresent(nil as Int16?) == .ifPresent(nil as JSONValue?))
        let int16 = random(Int16.self, in: .min ... .max)
        #expect(JSONValue.ifPresent(int16) == .ifPresent(.number(int16)))

        // Int32
        #expect(JSONValue.ifPresent(nil as Int32?) == .ifPresent(nil as JSONValue?))
        let int32 = random(Int32.self, in: .min ... .max)
        #expect(JSONValue.ifPresent(int32) == .ifPresent(.number(int32)))

        // Int64
        #expect(JSONValue.ifPresent(nil as Int64?) == .ifPresent(nil as JSONValue?))
        let int64 = random(Int64.self, in: .min ... .max)
        #expect(JSONValue.ifPresent(int64) == .ifPresent(.number(int64)))
    }


    @Test
    mutating func ifPresentUnsignedInteger() {
        // UInt
        #expect(JSONValue.ifPresent(nil as UInt?) == .ifPresent(nil as JSONValue?))
        let uint = random(UInt.self, in: 0 ... .max)
        #expect(JSONValue.ifPresent(uint) == .ifPresent(.number(uint)))

        // UInt8
        #expect(JSONValue.ifPresent(nil as UInt8?) == .ifPresent(nil as JSONValue?))
        let uint8 = random(UInt8.self, in: 0 ... .max)
        #expect(JSONValue.ifPresent(uint8) == .ifPresent(.number(uint8)))

        // UInt16
        #expect(JSONValue.ifPresent(nil as UInt16?) == .ifPresent(nil as JSONValue?))
        let uint16 = random(UInt16.self, in: 0 ... .max)
        #expect(JSONValue.ifPresent(uint16) == .ifPresent(.number(uint16)))

        // UInt32
        #expect(JSONValue.ifPresent(nil as UInt32?) == .ifPresent(nil as JSONValue?))
        let uint32 = random(UInt32.self, in: 0 ... .max)
        #expect(JSONValue.ifPresent(uint32) == .ifPresent(.number(uint32)))

        // UInt64
        #expect(JSONValue.ifPresent(nil as UInt64?) == .ifPresent(nil as JSONValue?))
        let uint64 = random(UInt64.self, in: 0 ... .max)
        #expect(JSONValue.ifPresent(uint64) == .ifPresent(.number(uint64)))
    }


    @Test
    mutating func numberFloatingPoint() {
        // Float32
        let float32 = random(Float32.self, in: -100 ... 100)
        #expect(JSONValue.number(float32) == .number(.floatingPoint(Float64(float32))))

        // Float64
        let float64 = random(Float64.self, in: -100 ... 100)
        #expect(JSONValue.number(float64) == .number(.floatingPoint(float64)))
    }


    @Test
    mutating func numberSignedInteger() {
        // Int
        let int = random(Int.self, in: .min ... .max)
        #expect(JSONValue.number(int) == .number(.integer(Int64(int))))

        // Int8
        let int8 = random(Int8.self, in: .min ... .max)
        #expect(JSONValue.number(int8) == .number(.integer(Int64(int8))))

        // Int16
        let int16 = random(Int16.self, in: .min ... .max)
        #expect(JSONValue.number(int16) == .number(.integer(Int64(int16))))

        // Int32
        let int32 = random(Int32.self, in: .min ... .max)
        #expect(JSONValue.number(int32) == .number(.integer(Int64(int32))))

        // Int64
        let int64 = random(Int64.self, in: .min ... .max)
        #expect(JSONValue.number(int64) == .number(.integer(int64)))
    }


    @Test
    mutating func numberUnsignedInteger() {
        // UInt
        let uint = random(UInt.self, in: 0 ... .max)
        #expect(JSONValue.number(uint) == .number(.unsignedInteger(UInt64(uint))))

        // UInt8
        let uint8 = random(UInt8.self, in: 0 ... .max)
        #expect(JSONValue.number(uint8) == .number(.unsignedInteger(UInt64(uint8))))

        // UInt16
        let uint16 = random(UInt16.self, in: 0 ... .max)
        #expect(JSONValue.number(uint16) == .number(.unsignedInteger(UInt64(uint16))))

        // UInt32
        let uint32 = random(UInt32.self, in: 0 ... .max)
        #expect(JSONValue.number(uint32) == .number(.unsignedInteger(UInt64(uint32))))

        // UInt64
        let uint64 = random(UInt64.self, in: 0 ... .max)
        #expect(JSONValue.number(uint64) == .number(.unsignedInteger(uint64)))
    }


    // MARK: - Literals

    @Test
    func literals() {
        let jsonValue: JSONValue = [
            [false, 1, "two", 3.0, nil],
            true,
            -1,
            2.718281828,
            nil,
            [
                "0": false,
                "1": 1,
                "2": "two",
                "3": 3.0,
                "4": nil,
                "5": [false, 1, "two", 3.0, nil],
                "6": false,
                "6": ["key": "value"],
            ],
            "string",
        ]

        let expectedJSONValue: JSONValue = [
            .array(
                [
                    .boolean(false),
                    .number(.integer(1)),
                    .string("two"),
                    .number(.floatingPoint(3.0)),
                    .null,
                ],
            ),
            .boolean(true),
            .number(.integer(-1)),
            .number(.floatingPoint(2.718281828)),
            .null,
            .object(
                [
                    "0": .boolean(false),
                    "1": .number(.integer(1)),
                    "2": .string("two"),
                    "3": .number(.floatingPoint(3.0)),
                    "4": .null,
                    "5": [.boolean(false), .number(.integer(1)), .string("two"), .number(.floatingPoint(3.0)), .null],
                    "6": ["key": .string("value")],
                ],
            ),
            .string("string")
        ]

        #expect(jsonValue == expectedJSONValue)
    }


    // MARK: - Any Converions

    @Test
    func arrayAnyConversion() throws {
        #expect(JSONValue(value: ["string", Date(), 1]) == nil)

        let array: [Any?] = [false, 1, "two", 3.0, nil]
        let jsonArray = try #require(JSONValue(value: array))
        #expect(jsonArray == [false, 1, "two", 3.0, nil])
        #expect(jsonArray.value as? NSArray == array as NSArray)
    }


    @Test
    mutating func booleanAnyConversion() throws {
        let value = randomBool()
        let jsonValue = try #require(JSONValue(value: value))
        #expect(jsonValue == .boolean(value))
        #expect(jsonValue.value as? Bool == value)
    }


    @Test
    mutating func dictionaryAnyConversion() throws {
        #expect(JSONValue(value: ["date": Date()]) == nil)

        let dictionary: [String: Any?] = ["0": false, "1": 1, "2": "two", "3": 3.0, "4": nil]
        let jsonObject = try #require(JSONValue(value: dictionary))
        #expect(jsonObject == ["0": false, "1": 1, "2": "two", "3": 3.0, "4": nil])
        #expect(jsonObject.value as? NSDictionary == dictionary as NSDictionary)
    }


    @Test
    mutating func ifPresentAnyConversion() throws {
        let notPresent = JSONValue.ifPresent(.ifPresent(nil as JSONValue?))
        #expect(notPresent.value == nil)

        let integer = random(Int.self, in: .min ... .max)
        let present = JSONValue.ifPresent(.ifPresent(.ifPresent(integer)))
        #expect(present.value as? Int64 == Int64(integer))
    }


    @Test
    mutating func floatingPointAnyConversion() throws {
        // Float32
        let float32 = random(Float32.self, in: -100 ... 100)
        let float32JSONValue = try #require(JSONValue(value: float32))
        #expect(float32JSONValue == JSONValue.number(float32))
        #expect(float32JSONValue.value as? Float64 == Float64(float32))

        // Float64
        let float64 = random(Float64.self, in: -100 ... 100)
        let float64JSONValue = try #require(JSONValue(value: float64))
        #expect(float64JSONValue == JSONValue.number(float64))
        #expect(float64JSONValue.value as? Float64 == float64)
    }


    @Test
    mutating func nilAnyConversion() throws {
        #expect(JSONValue(value: nil) == .null)
        #expect(JSONValue.null.value == nil)
    }


    @Test
    mutating func signedIntegerAnyConversion() throws {
        // Int
        let int = random(Int.self, in: .min ... .max)
        let intJSONValue = try #require(JSONValue(value: int))
        #expect(intJSONValue == JSONValue.number(int))
        #expect(intJSONValue.value as? Int64 == Int64(int))

        // Int8
        let int8 = random(Int8.self, in: .min ... .max)
        let int8JSONValue = try #require(JSONValue(value: int8))
        #expect(int8JSONValue == JSONValue.number(int8))
        #expect(int8JSONValue.value as? Int64 == Int64(int8))

        // Int16
        let int16 = random(Int16.self, in: .min ... .max)
        let int16JSONValue = try #require(JSONValue(value: int16))
        #expect(int16JSONValue == JSONValue.number(int16))
        #expect(int16JSONValue.value as? Int64 == Int64(int16))


        // Int32
        let int32 = random(Int32.self, in: .min ... .max)
        let int32JSONValue = try #require(JSONValue(value: int32))
        #expect(int32JSONValue == JSONValue.number(int32))
        #expect(int32JSONValue.value as? Int64 == Int64(int32))

        // Int64
        let int64 = random(Int64.self, in: .min ... .max)
        let int64JSONValue = try #require(JSONValue(value: int64))
        #expect(int64JSONValue == JSONValue.number(int64))
        #expect(int64JSONValue.value as? Int64 == int64)
    }


    @Test
    mutating func stringAnyConversion() throws {
        let string = randomBasicLatinString()
        let stringJSONValue = try #require(JSONValue(value: string))
        #expect(stringJSONValue == .string(string))
        #expect(stringJSONValue.value as? String == string)
    }


    @Test
    mutating func unsignedIntegerAnyConversion() throws {
        // UInt
        let uint = random(UInt.self, in: 0 ... .max)
        let uintJSONValue = try #require(JSONValue(value: uint))
        #expect(uintJSONValue == JSONValue.number(uint))
        #expect(uintJSONValue.value as? UInt64 == UInt64(uint))

        // UInt8
        let uint8 = random(UInt8.self, in: 0 ... .max)
        let uint8JSONValue = try #require(JSONValue(value: uint8))
        #expect(uint8JSONValue == JSONValue.number(uint8))
        #expect(uint8JSONValue.value as? UInt64 == UInt64(uint8))

        // UInt16
        let uint16 = random(UInt16.self, in: 0 ... .max)
        let uint16JSONValue = try #require(JSONValue(value: uint16))
        #expect(uint16JSONValue == JSONValue.number(uint16))
        #expect(uint16JSONValue.value as? UInt64 == UInt64(uint16))

        // UInt32
        let uint32 = random(UInt32.self, in: 0 ... .max)
        let uint32JSONValue = try #require(JSONValue(value: uint32))
        #expect(uint32JSONValue == JSONValue.number(uint32))
        #expect(uint32JSONValue.value as? UInt64 == UInt64(uint32))

        // UInt64
        let uint64 = random(UInt64.self, in: 0 ... .max)
        let uint64JSONValue = try #require(JSONValue(value: uint64))
        #expect(uint64JSONValue == JSONValue.number(uint64))
        #expect(uint64JSONValue.value as? UInt64 == uint64)
    }
}
