//
//  GibberishGeneratorTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 5/4/25.
//

import DevFoundation
import DevTesting
import Foundation
import Synchronization
import Testing

struct GibberishGeneratorTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()

    let generator = GibberishGenerator.latin


    @Test
    mutating func generateWordChoosesWordFromLexicon() {
        let word = generator.generateWord()
        #expect(generator.lexicon.words.contains(word))
    }


    @Test
    mutating func generateWordUsingRNGChoosesWordFromLexicon() {
        var localRNG = randomNumberGenerator

        let word1 = generator.generateWord(using: &localRNG)
        let word2 = generator.generateWord(using: &randomNumberGenerator)
        #expect(word1 == word2)
        #expect(generator.lexicon.words.contains(word1))
    }


    @Test
    mutating func generateSentenceChoosesRandomSentenceFromLexicon() throws {
        let sentence = generator.generateSentence()
        let firstLetter = try #require(sentence.first)
        #expect(firstLetter.isUppercase == generator.lexicon.capitalizesSentences)
        let sentenceWords = sentence.split(separator: generator.lexicon.sentenceSeparator)
            .map { $0.lowercased().replacing(/[^a-z]/, with: "") }
        #expect(sentenceWords.allSatisfy(generator.lexicon.words.contains(_:)))
    }


    @Test
    mutating func generateSentenceUsingRNGChoosesRandomSentenceFromLexicon() throws {
        var localRNG = randomNumberGenerator
        let sentence1 = generator.generateSentence(using: &localRNG)
        let sentence2 = generator.generateSentence(using: &randomNumberGenerator)
        #expect(sentence1 == sentence2)

        let firstLetter = try #require(sentence1.first)
        #expect(firstLetter.isUppercase == generator.lexicon.capitalizesSentences)
        let sentenceWords = sentence1.split(separator: generator.lexicon.sentenceSeparator)
            .map { $0.lowercased().replacing(/[^a-z]/, with: "") }
        #expect(sentenceWords.allSatisfy(generator.lexicon.words.contains(_:)))
    }


    @Test
    mutating func generateParagraphChoosesRandomSentencesFromLexiconWhenSentenceCountIsNil() throws {
        let generator = self.generator
        let paragraph = generator.generateParagraph()

        var sentenceCount = 0
        paragraph.enumerateSubstrings(
            in: paragraph.startIndex ..< paragraph.endIndex,
            options: .bySentences
        ) { (sentence, _, _, _) in
            guard let sentence else {
                Issue.record("sentence is nil")
                return
            }

            sentenceCount += 1

            guard let firstLetter = sentence.first else {
                Issue.record("first letter is nil")
                return
            }

            #expect(firstLetter.isUppercase == generator.lexicon.capitalizesSentences)
            let sentenceWords = sentence.split(separator: generator.lexicon.sentenceSeparator)
                .map { $0.lowercased().replacing(/[^a-z]/, with: "") }
            #expect(sentenceWords.allSatisfy(generator.lexicon.words.contains(_:)))
        }

        #expect(generator.lexicon.preferredSentencesPerParagraphRange.contains(sentenceCount))
    }


    @Test
    mutating func generateParagraphProducesCorrectSentenceCountWhenSentenceCountIsNonNil() throws {
        let generator = self.generator

        let expectedSentenceCount = randomInt(in: 10 ... 15)
        let paragraph = generator.generateParagraph(sentenceCount: expectedSentenceCount)

        var sentenceCount = 0
        paragraph.enumerateSubstrings(
            in: paragraph.startIndex ..< paragraph.endIndex,
            options: .bySentences
        ) { (sentence, _, _, _) in
            guard sentence != nil else {
                Issue.record("sentence is nil")
                return
            }

            sentenceCount += 1
        }

        #expect(sentenceCount == expectedSentenceCount)
    }


    @Test
    mutating func generateParagraphUsingRNGChoosesRandomSentencesFromLexiconWhenSentenceCountIsNil() throws {
        let generator = self.generator
        var localRNG = randomNumberGenerator
        let paragraph1 = generator.generateParagraph(using: &localRNG)
        let paragraph2 = generator.generateParagraph(using: &randomNumberGenerator)
        #expect(paragraph1 == paragraph2)

        var sentenceCount = 0
        paragraph1.enumerateSubstrings(
            in: paragraph1.startIndex ..< paragraph1.endIndex,
            options: .bySentences
        ) { (sentence, _, _, _) in
            guard let sentence else {
                Issue.record("sentence is nil")
                return
            }

            sentenceCount += 1

            guard let firstLetter = sentence.first else {
                Issue.record("first letter is nil")
                return
            }

            #expect(firstLetter.isUppercase == generator.lexicon.capitalizesSentences)
            let sentenceWords = sentence.split(separator: generator.lexicon.sentenceSeparator)
                .map { $0.lowercased().replacing(/[^a-z]/, with: "") }
            #expect(sentenceWords.allSatisfy(generator.lexicon.words.contains(_:)))
        }

        #expect(generator.lexicon.preferredSentencesPerParagraphRange.contains(sentenceCount))
    }


    @Test
    mutating func generateParagraphUsingRNGProducesCorrectSentenceCountWhenSentenceCountIsNonNil() throws {
        let generator = self.generator
        let expectedSentenceCount = randomInt(in: 10 ... 15)

        var localRNG = randomNumberGenerator
        let paragraph1 = generator.generateParagraph(using: &localRNG, sentenceCount: expectedSentenceCount)
        let paragraph2 = generator.generateParagraph(
            using: &randomNumberGenerator,
            sentenceCount: expectedSentenceCount
        )
        #expect(paragraph1 == paragraph2)

        var sentenceCount = 0
        paragraph1.enumerateSubstrings(
            in: paragraph1.startIndex ..< paragraph1.endIndex,
            options: .bySentences
        ) { (sentence, _, _, _) in
            guard sentence != nil else {
                Issue.record("sentence is nil")
                return
            }

            sentenceCount += 1
        }

        #expect(sentenceCount == expectedSentenceCount)
    }
}
