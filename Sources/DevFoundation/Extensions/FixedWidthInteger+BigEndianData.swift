//
//  FixedWidthInteger+BigEndianData.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 4/28/25.
//

import Foundation


extension FixedWidthInteger {
    /// The number of bytes used for the underlying binary representation of values of this type.
    static var byteWidth: Int {
        return bitWidth / 8
    }

    
    /// Creates a new integer using the big-endian bytes in a `Data` instance.
    ///
    /// Returns `nil` if the data does not contain exactly `byteWidth` bytes.
    ///
    /// - Parameter bigEndianData: A `Data` instance containing big-endian bytes.
    init?(bigEndianData: Data) {
        guard bigEndianData.count == Self.byteWidth else {
            return nil
        }

        // For slices of Data, startIndex != 0, which can cause problems, so create a new Data instance with
        // startIndex = 0 if needed
        let data = bigEndianData.startIndex != 0 ? Data(bigEndianData) : bigEndianData
        self.init(
            bigEndian: withUnsafePointer(to: data) { (pointer) in
                pointer.withMemoryRebound(to: Self.self, capacity: 1, \.pointee)
            }
        )
    }
    

    /// The integer’s big-endian representation as a `Data` instance.
    var bigEndianData: Data {
        return withUnsafeBytes(of: bigEndian) { (pointer) in
            Data(pointer[0 ..< Self.byteWidth])
        }
    }
}
