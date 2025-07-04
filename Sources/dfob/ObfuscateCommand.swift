//
//  ObfuscateCommand.swift
//  ObfuscateTool
//
//  Created by Prachi Gauriar on 4/30/25.
//

import ArgumentParser
import DevFoundation
import Foundation

/// A command for obfuscating and deobfuscating data.
@main
struct ObfuscateCommand: AsyncParsableCommand {
    /// The action that the command should take.
    enum Action: EnumerableFlag {
        /// Indicates that the command should obfuscate.
        case obfuscate

        /// Indicates that the command should deobfuscate.
        case deobfuscate


        static func name(for value: Action) -> NameSpecification {
            switch value {
            case .deobfuscate:
                return [.customShort("D"), .long]
            case .obfuscate:
                return [.customShort("O"), .long]
            }
        }
    }


    /// The command’s action.
    @Flag(help: "Whether the tool should obfuscate or deobfuscate.")
    var action: Action

    /// The command’s input path.
    @Option(name: [.customShort("i"), .long], help: "The path of the input file. If unspecified, stdin is used.")
    var inputPath: String?

    /// The command’s output path.
    @Option(name: [.customShort("o"), .long], help: "The path of the output file. If unspecified, stdout is used.")
    var outputPath: String?


    static var configuration: CommandConfiguration {
        return .init(abstract: "A tool for obfuscating or deobfuscating an input.")
    }


    /// The file handle that the command should use for input.
    ///
    /// If ``inputPath`` is `nil`, returns `FileHandle.standardInput`. Otherwise attempts to open ``inputPath`` for
    /// reading. If that fails, a fatal error occurs.
    lazy var inputFileHandle: FileHandle = { () -> FileHandle in
        guard let inputPath = (inputPath as? NSString)?.standardizingPath else {
            return FileHandle.standardInput
        }

        guard let fileHandle = FileHandle(forReadingAtPath: inputPath) else {
            fatalError("Could not open input file at \(inputPath).")
        }

        return fileHandle
    }()


    /// The file handle that the command should use for ouput.
    ///
    /// If ``outputPath`` is `nil`, returns `FileHandle.standardOutput`. Otherwise attempts to create a file for writing
    /// at ``outputPath``. If that fails, a fatal error occurs.
    lazy var outputFileHandle: FileHandle = {
        guard let outputPath = (outputPath as? NSString)?.standardizingPath else {
            return FileHandle.standardOutput
        }

        guard
            FileManager.default.createFile(atPath: outputPath, contents: nil),
            let fileHandle = FileHandle(forWritingAtPath: outputPath)
        else {
            fatalError("Could not open output file at \(outputPath).")
        }

        return fileHandle
    }()


    mutating func run() async throws {
        let inputData = try inputFileHandle.read(upToCount: .max) ?? Data()

        switch action {
        case .deobfuscate:
            let deobfuscatedData = try inputData.deobfuscated(
                keySizeType: UInt8.self,
                messageSizeType: UInt32.self
            )
            try outputFileHandle.write(contentsOf: deobfuscatedData)
        case .obfuscate:
            let obfuscatedData = try inputData.obfuscated(
                withKey: UUID().data,
                keySizeType: UInt8.self,
                messageSizeType: UInt32.self,
            )
            try outputFileHandle.write(contentsOf: obfuscatedData)
        }
    }
}


extension UUID {
    var data: Data {
        return withUnsafeBytes(of: uuid, Data.init(_:))
    }
}
