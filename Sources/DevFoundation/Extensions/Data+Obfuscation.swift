//
//  Data+Obfuscation.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 4/28/25.
//

import Foundation

extension Data {
    /// Returns an obfuscated form of the data instance.
    ///
    /// `keySizeType` and `messageSizeType` must be large enough to be able to represent the key’s and message’s sizes.
    /// If either type is too small, an error is thrown during obfuscation.
    ///
    /// - Parameters:
    ///   - key: The key with which to obfuscate the data. Must not be empty.
    ///   - keySizeType: The type with which to store the key’s size. Throws an error if the type is too small to
    ///     represent the key size.
    ///   - messageSizeType: The type with which to store the size of the message, i.e., the data instance. Throws an
    ///     error if the type is too small to represent the message’s size.
    public func obfuscated<MessageSize, KeySize>(
        withKey key: Data,
        keySizeType: KeySize.Type,
        messageSizeType: MessageSize.Type
    ) throws -> Data
    where
        KeySize: FixedWidthInteger,
        MessageSize: FixedWidthInteger
    {
        guard count <= MessageSize.max else {
            throw DataObfuscationError.messageSizeExceedsMaximum
        }

        guard key.count <= KeySize.max else {
            throw DataObfuscationError.keySizeExceedsMaximum
        }

        let message = self ^ key
        var output = MessageSize(message.count).bigEndianData
        output.append(message)
        output.append(KeySize(key.count).bigEndianData)
        output.append(key)
        return output
    }


    /// Returns a deobfuscated form of the data instance.
    ///
    /// The data is assumed to have been obfuscated using ``obfuscated(withKey:keySizeType:messageSizeType:)`` using the
    /// same values of `keySizeType` and `messageSizeType`.
    ///
    /// - Parameters:
    ///   - keySizeType: The key size type used to obfuscate the data.
    ///   - messageSizeType: The message size type used to obfuscate the data.
    public func deobfuscated<MessageSize, KeySize>(
        keySizeType: KeySize.Type,
        messageSizeType: MessageSize.Type
    ) throws -> Data
    where
        KeySize: FixedWidthInteger & Sendable,
        MessageSize: FixedWidthInteger & Sendable
    {
        guard let (message, keyStartIndex) = extractFieldData(at: 0, sizeType: messageSizeType) else {
            throw DataDeobfuscationError.invalidMessage
        }

        guard let (key, _) = extractFieldData(at: keyStartIndex, sizeType: keySizeType) else {
            throw DataDeobfuscationError.invalidKey
        }

        return message ^ key
    }


    /// Extracts a field from the data instance starting at a given index.
    ///
    /// Fields are stored in the data as:
    ///
    ///     <fieldSize> <field>
    ///
    /// where _fieldSize_ is the size of field and _field_ is the field data itself.
    ///
    /// - Parameters:
    ///   - index: The index at which the field data starts.
    ///   - sizeType: The integer type with which to extract the data’s size.
    /// - Returns: The field’s data and the index immediately after its last byte. Returns `nil` if the field could not
    ///   be extracted.
    private func extractFieldData<FieldSize>(
        at index: Int,
        sizeType: FieldSize.Type
    ) -> (Data, Int)?
    where FieldSize: FixedWidthInteger & Sendable {
        let fieldSizeEndIndex = index + FieldSize.byteWidth
        guard endIndex >= fieldSizeEndIndex else {
            return nil
        }

        let fieldSizeData = self[index ..< fieldSizeEndIndex]
        guard
            let fieldSize = FieldSize(bigEndianData: fieldSizeData).flatMap(Int.init(exactly:)),
            fieldSize > 0
        else {
            return nil
        }

        let dataStartIndex = fieldSizeEndIndex
        let dataEndIndex = dataStartIndex + fieldSize
        guard endIndex >= dataEndIndex else {
            return nil
        }

        return (self[dataStartIndex ..< dataEndIndex], dataEndIndex)
    }


    /// Returns the result of performing a bitwise XOR on the elements of two `Data` instances.
    ///
    /// The result of this operation will always have the same number of bytes as `lhs`. If the `rhs` has fewer elements
    /// than `lhs`, it will be extended by repeating its bytes its the same size as `lhs`. If `rhs` is longer, only its
    /// first `lhs.count` bytes will be used.
    ///
    /// - Note: This operation is not commutative.
    ///
    /// - Parameters:
    ///   - lhs: A data instance.
    ///   - rhs: Another data instance. Must not be empty.
    fileprivate static func ^ (lhs: Data, rhs: Data) -> Data {
        precondition(!rhs.isEmpty, "rhs must be non-empty")
        return Data(
            lhs.enumerated().map { (i, byte) in
                byte ^ rhs[rhs.startIndex + i % rhs.count]
            }
        )
    }
}


/// Errors that can be thrown during data obfuscation.
enum DataObfuscationError: Error {
    /// Indicates that the key is too large to be stored using the given key size type.
    case keySizeExceedsMaximum

    /// Indicates that the message is too large to be stored using the given message size type.
    case messageSizeExceedsMaximum
}


/// Errors that can be thrown during data deobfuscation.
enum DataDeobfuscationError: Error {
    /// Indicates that a key could not be extracted from the obfuscated data.
    case invalidKey

    /// Indicates that a message could not be extracted from the obfuscated data.
    case invalidMessage
}
