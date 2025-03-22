//
//  TopLevelCoding.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/19/25.
//

import Foundation


/// A type that can decode `Decodable` values.
///
/// This type differs from Combine’s `TopLevelDecoder` in that it also requires a mutable ``userInfo`` dictionary.
public protocol TopLevelDecoder<Input>: AnyObject {
    /// The type this decoder accepts.
    associatedtype Input

#if compiler(>=6.1)
    /// A dictionary you use to customize the decoding process by providing contextual information.
    var userInfo: [CodingUserInfoKey: any Sendable] { get set }
#else
    /// A dictionary you use to customize the decoding process by providing contextual information.
    var userInfo: [CodingUserInfoKey: Any] { get set }
#endif

    /// Decodes a value of the specified type from an input.
    ///
    /// - Parameters:
    ///   - type: The type of value to decode.
    ///   - input: The input from which to decode the type.
    func decode<Value>(_ type: Value.Type, from input: Input) throws -> Value where Value: Decodable
}


/// A type that can encode `Encodable` values.
///
/// This type differs from Combine’s `TopLevelEncoder` in that it also requires a mutable ``userInfo`` dictionary.
public protocol TopLevelEncoder<Output>: AnyObject {
    /// The type this encoder produces.
    associatedtype Output

#if compiler(>=6.1)
    /// A dictionary you use to customize the encoding process by providing contextual information.
    var userInfo: [CodingUserInfoKey: any Sendable] { get set }
#else
    /// A dictionary you use to customize the encoding process by providing contextual information.
    var userInfo: [CodingUserInfoKey: Any] { get set }
#endif

    /// Encodes a value of the specified type.
    ///
    /// - Parameter value: The value to encode.
    func encode<Value>(_ value: Value) throws -> Output where Value: Encodable
}


extension JSONDecoder: TopLevelDecoder { }
extension JSONEncoder: TopLevelEncoder { }

extension PropertyListDecoder: TopLevelDecoder { }
extension PropertyListEncoder: TopLevelEncoder { }


// MARK: - Decoding Top-Level Keys

extension CodingUserInfoKey {
    /// A coding user info key whose corresponding value is the top-level key that a `TopLevelKeyedValue` will decode.
    ///
    /// This is set in ``TopLevelDecoder/decode(_:from:topLevelKey:)`` and read from `ToplevelKeyedValue.init(from:)`.
    fileprivate static let topLevelKeyToDecode = CodingUserInfoKey(rawValue: "DevFoundation.topLevelKeyToDecode")!
}


extension TopLevelDecoder {
    /// Decodes and returns a value of the specified type, starting at the specified top-level key in the input.
    ///
    /// - Parameters:
    ///   - type: The type of value to decode.
    ///   - input: The input from which to decode the type.
    ///   - topLevelKey: The top-level key at which to start decoding.
    public func decode<Key, Value>(_ type: Value.Type, from input: Input, topLevelKey: Key) throws -> Value
    where Key: CodingKey, Value: Decodable {
        // Set the top-level key to decode. Clear it before returning from this function.
        userInfo[.topLevelKeyToDecode] = topLevelKey
        defer { userInfo[.topLevelKeyToDecode] = nil }

        return try decode(TopLevelKeyedValue<Key, Value>.self, from: input).value
    }
}


/// A value associated with a top-level coding key.
///
/// `TopLevelKeyedValue`s are used to decode a top-level key from a decoder’s input. The key to decode is passed to the
/// type via the decoder’s `userInfo` dictionary.
private struct TopLevelKeyedValue<Key, Value>: Decodable where Key: CodingKey, Value: Decodable {
    /// The decoded value.
    let value: Value


    init(from decoder: any Decoder) throws {
        let key = decoder.userInfo[.topLevelKeyToDecode] as! Key
        let container = try decoder.container(keyedBy: Key.self)
        self.value = try container.decode(Value.self, forKey: key)
    }
}
