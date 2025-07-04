//
//  ObfuscateCommandTests.swift
//  ObfuscateTool
//
//  Created by Prachi Gauriar on 4/30/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

@testable import ArgumentParser
@testable import dfob

struct ObfuscateCommandTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    func nameForAction() {
        #expect(ObfuscateCommand.Action.name(for: .deobfuscate).elements == [.customShort("D"), .long])
        #expect(ObfuscateCommand.Action.name(for: .obfuscate).elements == [.customShort("O"), .long])
    }


    @Test
    func abstractIsNotEmpty() {
        #expect(!ObfuscateCommand.configuration.abstract.isEmpty)
    }


    @Test
    func usesStandardInputAndOutputWhenPathsAreUnspecified() throws {
        for actionArgument in ["--deobfuscate", "--obfuscate"] {
            var command = try ObfuscateCommand.parse([actionArgument])
            #expect(command.inputFileHandle == .standardInput)
            #expect(command.outputFileHandle == .standardOutput)
        }
    }


    @Test
    mutating func usesFilesWhenPathsAreSpecified() throws {
        let fileManager = FileManager.default

        for actionArgument in ["--deobfuscate", "--obfuscate"] {
            let inputPath = randomTemporaryFilePath()
            let outputPath = randomTemporaryFilePath()

            fileManager.createFile(atPath: inputPath, contents: nil)

            var command = try ObfuscateCommand.parse(
                [actionArgument, "--input-path", inputPath, "--output-path", outputPath]
            )

            #expect(command.inputFileHandle != .standardInput)
            #expect(command.outputFileHandle != .standardOutput)

            #expect(FileManager.default.fileExists(atPath: outputPath))
        }
    }


    @Test
    mutating func inputIsActuallyObfuscatedAndDeobfuscated() async throws {
        let fileManager = FileManager.default

        let messagePath = randomTemporaryFilePath()
        let obfuscatedMessagePath = randomTemporaryFilePath()
        let message = randomData(count: 128)

        // Create the message file
        fileManager.createFile(atPath: messagePath, contents: message)

        // Run the obfuscate command
        var obfuscateCommand = try ObfuscateCommand.parse(
            ["--obfuscate", "--input-path", messagePath, "--output-path", obfuscatedMessagePath]
        )

        try await obfuscateCommand.run()

        // Verify that the obfuscated data is correct.
        let obfuscatedData = try Data(contentsOf: URL(filePath: obfuscatedMessagePath))
        let expectedKey = obfuscatedData[(4 + message.count + 1) ..< obfuscatedData.count]
        let expectedObfuscatedData = try message.obfuscated(
            withKey: expectedKey,
            keySizeType: UInt8.self,
            messageSizeType: UInt32.self
        )

        #expect(obfuscatedData == expectedObfuscatedData)

        // Run the deobfuscate command
        let deobfuscatedMessagePath = randomTemporaryFilePath()
        var deobfuscateCommand = try ObfuscateCommand.parse(
            ["--deobfuscate", "--input-path", obfuscatedMessagePath, "--output-path", deobfuscatedMessagePath]
        )

        try await deobfuscateCommand.run()
        let deobfuscatedData = try Data(contentsOf: URL(filePath: deobfuscatedMessagePath))

        // Verify that the output is the same as our original message
        #expect(deobfuscatedData == message)
    }


    private mutating func randomTemporaryFilePath() -> String {
        return "\(NSTemporaryDirectory())/\(randomAlphanumericString(count: 20))"
    }
}
