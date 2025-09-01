//
//  GibberishGenerator.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 5/4/25.
//

import Foundation

/// An object that generates gibberish.
///
/// Each gibberish generator can generate words, sentences or paragraphs. A generator’s words and sentences are stored
/// in a ``GibberishGenerator/Lexicon``.  DevFoundation includes a lexicon for gibberish that ressmebles Latin—commonly
/// referred to as _Lorem Ipsum_—but you can create your own as well.
///
/// - Note: While `Lexicon` is an attempt to make `GibberishGenerator` language-agnostic, it may contain implicit
///   assumptions that produce incorrect results in non-Latin languages.
public struct GibberishGenerator: Sendable {
    /// A set words, sentences templates, and rules for generating gibberish.
    public struct Lexicon: Codable, Hashable, Sendable {
        /// Whether sentences produced using the lexicon should be capitalized.
        public let capitalizesSentences: Bool

        /// The identifier for the gibberish’s locale.
        ///
        /// This value is used to capitalize sentences.
        public let localeIdentifier: String

        /// A range encompassing the preferred number of sentences in a paragraph.
        ///
        /// This value is used to generate sentences when no sentence count is specified.
        public let preferredSentencesPerParagraphRange: ClosedRange<Int>

        /// The lexicon’s sentence separator.
        ///
        /// This string is used to separate sentences in a paragraph.
        public let sentenceSeparator: String

        /// The lexicon’s sentence templates.
        ///
        /// Must be non-empty.
        public let sentenceTemplates: [String]

        /// The token that denotes a word in the lexicon’s sentence templates.
        ///
        /// Must be non-empty.
        public let templateWordToken: String

        /// The lexicon’s words.
        ///
        /// Must be non-empty.
        public let words: [String]


        /// Creates a new lexicon.
        ///
        /// - Parameters:
        ///   - capitalizesSentences: Whether sentences produced using the lexicon should be capitalized.
        ///   - localeIdentifier: The identifier for the gibberish’s locale.
        ///   - preferredSentencesPerParagraphRange: A range encompassing the preferred number of sentences in a
        ///     paragraph. The lower bound of this range must be positive.
        ///   - sentenceSeparator: The lexicon’s sentence separator. This string is used to separate sentences in a
        ///     paragraph.
        ///   - sentenceTemplates: The lexicon’s sentence templates. Must be non-empty.
        ///   - templateWordToken: The token that denotes a word in the lexicon’s sentence templates. Must be non-empty.
        ///   - words: The lexicon’s words. Must be non-empty.
        public init(
            capitalizesSentences: Bool,
            localeIdentifier: String,
            preferredSentencesPerParagraphRange: ClosedRange<Int>,
            sentenceSeparator: String,
            sentenceTemplates: [String],
            templateWordToken: String,
            words: [String]
        ) {
            precondition(
                preferredSentencesPerParagraphRange.lowerBound > 0,
                "preferredSentencesPerParagraphRange must have a positive lower bound"
            )
            precondition(!sentenceTemplates.isEmpty, "sentenceTemplates must be non-empty")
            precondition(!templateWordToken.isEmpty, "templateWordToken must be non-empty")
            precondition(!words.isEmpty, "words must be non-empty")

            self.capitalizesSentences = capitalizesSentences
            self.localeIdentifier = localeIdentifier
            self.preferredSentencesPerParagraphRange = preferredSentencesPerParagraphRange
            self.sentenceSeparator = sentenceSeparator
            self.sentenceTemplates = sentenceTemplates
            self.templateWordToken = templateWordToken
            self.words = words
        }
    }


    /// The generator’s lexicon.
    public let lexicon: Lexicon

    /// The lexicon’s locale.
    let locale: Locale


    /// Creates a new generator using the specified lexicon.
    ///
    /// - Parameter lexicon: The generator’s lexicon.
    public init(lexicon: Lexicon) {
        self.lexicon = lexicon
        self.locale = Locale(identifier: lexicon.localeIdentifier)
    }


    /// Generates a word of gibberish using a specific random number generator.
    ///
    /// - Parameter randomNumberGenerator: The random number generator to use during generation.
    /// - Returns: A random word from the generator’s lexicon.
    public func generateWord(using randomNumberGenerator: inout some RandomNumberGenerator) -> String {
        lexicon.words.randomElement(using: &randomNumberGenerator)!
    }


    /// Generates a word of gibberish.
    ///
    /// This function uses the system random number generator during generation.
    ///
    /// - Returns: A random word from the generator’s lexicon.
    public func generateWord() -> String {
        var randomNumberGenerator = SystemRandomNumberGenerator()
        return generateWord(using: &randomNumberGenerator)
    }


    /// Generates a sentence of gibberish using a specific random number generator.
    ///
    /// - Parameter randomNumberGenerator: The random number generator to use during generation.
    /// - Returns: A sentence using a template and words from the generator’s lexicon.
    public func generateSentence(using randomNumberGenerator: inout some RandomNumberGenerator) -> String {
        var sentence = lexicon.sentenceTemplates.randomElement(using: &randomNumberGenerator)!

        var range = sentence.range(of: lexicon.templateWordToken)
        var isFirstWord = true
        while range != nil {
            var word = lexicon.words.randomElement(using: &randomNumberGenerator)!
            if isFirstWord && lexicon.capitalizesSentences {
                word = word.capitalized(with: locale)
            }
            sentence.replaceSubrange(range!, with: word)
            isFirstWord = false
            range = sentence.range(of: lexicon.templateWordToken)
        }

        return sentence
    }


    /// Generates a sentence of gibberish.
    ///
    /// This function uses the system random number generator during generation.
    ///
    /// - Returns: A sentence using a template and words from the generator’s lexicon.
    public func generateSentence() -> String {
        var randomNumberGenerator = SystemRandomNumberGenerator()
        return generateSentence(using: &randomNumberGenerator)
    }


    /// Generates a paragraph of gibberish using a specific random number generator.
    ///
    /// - Parameters:
    ///   - randomNumberGenerator: The random number generator to use during generation.
    ///   - sentenceCount: The number of sentences that the paragraph should include. If `nil`, a random value is chosen
    ///     within the range of the lexicon’s preferred number of sentences.
    /// - Returns: A sentence using a template and words from the generator’s lexicon.
    public func generateParagraph(
        using randomNumberGenerator: inout some RandomNumberGenerator,
        sentenceCount: Int? = nil
    ) -> String {
        // swift-format-ignore
        let sentenceCount = sentenceCount ?? Int.random(
            in: lexicon.preferredSentencesPerParagraphRange,
            using: &randomNumberGenerator
        )

        return (0 ..< sentenceCount)
            .map { _ in generateSentence(using: &randomNumberGenerator) }
            .joined(separator: lexicon.sentenceSeparator)
    }


    /// Generates a paragraph of gibberish.
    ///
    /// - Parameter sentenceCount: The number of sentences that the paragraph should include. If `nil`, a random value
    ///   is chosen within the range of the lexicon’s preferred number of sentences.
    /// - Returns: A paragraph using sentence templates and words from the generator’s lexicon.
    public func generateParagraph(sentenceCount: Int? = nil) -> String {
        var randomNumberGenerator = SystemRandomNumberGenerator()
        return generateParagraph(using: &randomNumberGenerator, sentenceCount: sentenceCount)
    }
}


extension GibberishGenerator {
    /// A generator that produces gibberish that ressembles Latin.
    public static let latin: GibberishGenerator = {
        // We could put this in a file, but it’s relatively small and saves us from needing a bundle.
        let latinLexicon = Lexicon(
            capitalizesSentences: true,
            localeIdentifier: "en",
            preferredSentencesPerParagraphRange: 3 ... 7,
            sentenceSeparator: " ",
            sentenceTemplates: [
                "@ @ @, @ @, @ @, @ @ @ @ @.",
                "@ @ @, @ @ @ @, @ @ @ @.",
                "@ @ @.",
                "@ @ @ @.",
                "@ @ @ @ @, @ @ @.",
                "@ @ @ @ @; @ @ @ @ @.",
                "@ @ @ @ @.",
                "@ @ @ @ @ @.",
                "@ @ @ @ @ @ @, @ @ @ @ @ @.",
                "@ @ @ @ @ @ @.",
                "@ @ @ @ @ @ @ @ @; @ @ @ @ @ @.",
                "@ @ @ @ @ @ @ @ @.",
                "@ @ @ @ @ @ @ @ @ @ @.",
                "@ @ @ @ @ @ @ @ @, @ @ @.",
                "@ @ @ @ @ @ @ @; @ @ @ @.",
                "@ @ @ @ @, @ @ @ @ @ @ @ @ @.",
                "@ @ @, @ @ @ @ @ @, @ @ @.",
                "@ @ @ @ @ @ @, @ @ @, @ @ @ @.",
            ],
            templateWordToken: "@",
            words: [
                "a", "ac", "accum", "accummy", "accumsan", "accumsandre", "aci", "aciduipis", "acidunt", "aciliqu",
                "aciliquis", "acilit", "acing", "acipisl", "acipit", "acipsus", "ad", "adiam", "adiat", "adiatet",
                "adignim", "adignit", "adio", "adion", "adionse", "adionsed", "adionsequat", "adipis", "adipiscing",
                "adipsusting", "adipsusto", "adit", "aenean", "aliquam", "aliquat", "aliquatem", "aliquet", "aliqui",
                "aliquip", "aliquipsum", "aliquis", "aliquisi", "alis", "aliscil", "aliscin", "alisi", "alisis",
                "alisit", "alismolum", "alit", "am", "amcommo", "amconsecte", "amconsendre", "amconumsan", "amet",
                "ametum", "ametumm", "andrero", "ante", "aptent", "arcu", "at", "ate", "atinit", "ationullaoret",
                "atis", "atueros", "atummy", "auctor", "augait", "augiam", "augiat", "augue", "auguer", "auguero",
                "aut", "autat", "autatie", "aute", "autem", "autet", "autpate", "bibendum", "bla", "blam", "blamet",
                "blandipisisi", "blandit", "blaor", "blaore", "cilit", "cillum", "cipsusto", "class", "commod",
                "commodipis", "commodo", "commodolor", "commolor", "commolum", "commy", "con", "condimentum", "congue",
                "conse", "consecte", "consectem", "consectetuer", "consed", "consenibh", "consenisim", "consenit",
                "consent", "consequ", "consequam", "consequat", "consequipis", "consequipit", "consequis", "conubia",
                "conullandiam", "conulluptat", "conulputem", "conum", "convallis", "cor", "core", "coreet", "coreetue",
                "corem", "coreraestrud", "corero", "corperc", "cras", "cubilia", "cum", "curabitur", "curae", "cursus",
                "dapibus", "del", "delendipis", "delent", "deliquatue", "deliqui", "delit", "diam", "diamcom",
                "diamcon", "diamet", "diat", "dictum", "dictumst", "digna", "dignis", "dignissequis", "dignissim",
                "dio", "dionse", "dionsenit", "dionull", "dip", "dipiscipit", "dipissit", "dis", "dit", "do", "dolendi",
                "dolendit", "dolendrem", "dolendrer", "dolenim", "dolent", "dolese", "dolesecte", "dolessed", "dolessi",
                "dolobor", "dolobore", "doloboreet", "doloborem", "doloborper", "dolor", "dolore", "doloreet",
                "dolorem", "dolorer", "dolorerat", "dolorpe", "dolorper", "dolortis", "dolortisl", "dolum", "dolummy",
                "dolumsan", "doluptat", "doluptatue", "dolut", "dolutem", "dolutpat", "donec", "dui", "duis", "duisi",
                "duisit", "duismolobore", "dunt", "ea", "ed", "eetuercil", "egestas", "eget", "el", "eleifend",
                "elementum", "elenisit", "elenit", "elese", "elesequ", "elesto", "eliquatum", "elis", "elit", "endio",
                "endre", "endreet", "enibh", "enim", "enis", "eniscip", "enisit", "enissim", "enississe", "enit", "ent",
                "er", "eraestie", "eraestrud", "erat", "erciduis", "ercilis", "ercincil", "erit", "eriure", "eriurer",
                "ero", "eros", "erostin", "ese", "esectem", "esed", "esequat", "esequi", "esequis", "esse", "essequis",
                "essi", "essisis", "essisit", "essit", "est", "estie", "esting", "estio", "esto", "estrud", "et",
                "etiam", "etueratem", "etuerci", "etuercillan", "etuerostrud", "etum", "eu", "eugait", "eugiam",
                "eugiamconse", "eugiamcorer", "eugiat", "eugiate", "eugiatum", "eugue", "euguer", "euguercinis",
                "euguero", "eui", "euipit", "euis", "euiscip", "euisi", "euisl", "euismod", "euissim", "eum", "eummy",
                "eumsan", "eumsandre", "ex", "exer", "exerat", "exercilit", "exercillaore", "exercipsum", "exeriure",
                "exero", "exeros", "exerostin", "faccum", "faccummy", "faccumsan", "faci", "facidui", "faciduisi",
                "faciduisit", "facidunt", "faciliq", "faciliquis", "facilisi", "facilisis", "facilisse", "facillum",
                "facin", "facinci", "facincil", "facincilit", "facing", "facipsu", "facipsum", "fames", "faucibus",
                "felis", "fermentum", "feu", "feugait", "feugiam", "feugiamet", "feugiat", "feugiatue", "feugue",
                "feuguer", "feuguerci", "feuguerit", "feuguerostin", "feui", "feuipsumsan", "feuisi", "feuismodolor",
                "feum", "fringilla", "fusce", "gait", "gravida", "habitant", "habitasse", "hac", "hendigna", "hendip",
                "hendipisim", "hendre", "hendrerit", "henim", "henis", "henisi", "henissi", "henit", "hent",
                "hymenaeos", "iaculis", "id", "idunt", "il", "iliquamcon", "iliquat", "iliqui", "iliquipisl", "iliquis",
                "iliquiscipis", "ilis", "ilit", "illa", "illam", "illaor", "illuptatie", "im", "imperdiet", "in",
                "inceptos", "inci", "inciduipit", "incinci", "incing", "incinim", "incinis", "incipis", "ing", "iniam",
                "iniatue", "inim", "integer", "interdum", "ip", "ipis", "ipisci", "ipiscip", "ipisim", "ipisl", "ipit",
                "ipsum", "ipsumsan", "ipsusci", "ipsuscidunt", "ipsustie", "ipsustrud", "iquatum", "iril", "irilit",
                "irilla", "irillam", "irit", "iriure", "iscidunt", "iscing", "iscipit", "isisiscilit", "ismolore",
                "issectem", "issendiam", "issequi", "iure", "iureet", "iurem", "iurercing", "iuscing", "iuscipit",
                "iustrud", "justo", "la", "lacinia", "lacus", "lam", "lamconullaor", "lan", "landignibh", "landrem",
                "laor", "laore", "laoreet", "laortie", "lectus", "leo", "libero", "ligula", "litora", "lobor", "lobore",
                "loboreet", "loborer", "loborper", "loborperci", "loborting", "lobortio", "lobortis", "lor", "lore",
                "loreetue", "lorem", "lorer", "lorper", "lorpercidunt", "luctus", "lum", "lumsan", "luptat", "luptatum",
                "lut", "lutat", "lute", "lutpat", "maecenas", "magna", "magniamet", "magniat", "magnim", "magnis",
                "magnit", "malesuada", "massa", "mattis", "mauris", "metus", "mi", "min", "mincidunt", "minciliquat",
                "miniat", "minit", "mod", "modiam", "modignis", "modion", "modionsed", "modipsu", "modipsustie",
                "modit", "modo", "modolore", "modolutem", "molestie", "mollis", "molor", "molore", "montes", "morbi",
                "msandre", "mus", "nam", "nascetur", "natoque", "nec", "neque", "netus", "niam", "niamcon", "niamet",
                "niat", "nibh", "nim", "nis", "niscidu", "niscilit", "nisim", "nisit", "nisl", "nissi", "nit", "non",
                "nonse", "nonsed", "nonsenibh", "nonsequ", "nonsequam", "nonsequi", "nonulla", "nonulput",
                "nonulputate", "nonum", "nonummy", "nos", "nostie", "nostissi", "nosto", "nostra", "nostrud", "nulla",
                "nullam", "nullandigna", "nullandrem", "nullaor", "nullum", "nulluptatie", "nullut", "nullute",
                "nulput", "nulputpatum", "num", "nummolorem", "nummy", "numsan", "numsandre", "nunc", "obor", "od",
                "odigna", "odio", "odionsequip", "odipsumsan", "odolobor", "odolor", "odolore", "odolorperos",
                "odolupt", "olenit", "olorper", "onse", "orci", "ornare", "os", "ostrud", "parturient", "patin", "pede",
                "pellentesque", "penatibus", "per", "peraese", "pharetra", "phasellus", "placerat", "platea", "porta",
                "porttitor", "posuere", "potenti", "praesed", "praesent", "praessequate", "praestie", "praestis",
                "prat", "prate", "pratisl", "pretium", "primis", "proin", "psusto", "psustrud", "pulvinar", "purus",
                "put", "quam", "quamconsequi", "quamet", "quat", "quatet", "quatie", "quatio", "quation", "quatuer",
                "quatuerit", "quatums", "qui", "quip", "quipsum", "quis", "quiscilit", "quisi", "quisisl", "quisl",
                "quismod", "quisque", "quissi", "rcilis", "rhoncus", "ridiculus", "rilisit", "rilit", "risus", "ros",
                "rostisi", "rud", "rutrum", "sagittis", "sandigna", "sapien", "scelerisque", "scilis", "scillum", "se",
                "secte", "sectem", "sed", "sem", "semper", "sendio", "senectus", "senisl", "sequam", "sequat", "sequis",
                "si", "sim", "sis", "sismolore", "sit", "sociis", "sociosqu", "sodales", "sollicitudin", "ssisci",
                "stincil", "sum", "summy", "sumsan", "sumsandre", "susci", "susciduipit", "suscil", "suscilla",
                "suscin", "suscipit", "suspendisse", "susto", "sustrud", "taciti", "tat", "tatet", "tatiniat",
                "tatisit", "tatue", "tatum", "tatumsan", "te", "tellus", "tem", "tempor", "tempus", "tet", "tie", "tin",
                "tincidunt", "tinit", "tio", "tion", "tionsenis", "tionsequi", "tionulla", "tis", "tisi", "tisis",
                "tismolortis", "torquent", "tortor", "tristique", "tue", "turpis", "uamconum", "uissit", "ulla",
                "ullam", "ullamcorper", "ullan", "ullaor", "ullut", "ullutat", "ullutpat", "ulputat", "ulputpat",
                "ultrices", "ultricies", "uptatem", "urna", "ut", "utat", "utate", "utatum", "ute", "utet", "utetue",
                "utetumm", "utpat", "utpationse", "varius", "vehicula", "vel", "velenibh", "velenis", "velenisit",
                "velent", "velesse", "velessectem", "velessequis", "velessim", "velestio", "velestionse", "velesto",
                "veliquat", "veliqui", "veliquisit", "velis", "velisim", "velisit", "velisl", "velit", "vendiam",
                "vendiatie", "vendipissit", "vendre", "venenatis", "venibh", "venim", "venit", "vent", "ver", "verci",
                "vercilisit", "verit", "veriusto", "vero", "veros", "verostin", "vestibulum", "vitae", "vivamus",
                "viverra", "volenisis", "volesed", "volobore", "volor", "volore", "volorerci", "voloreros", "volumsan",
                "volut", "volutpat", "vulla", "vullam", "vullan", "vullandigna", "vullandio", "vulluptat",
                "vulluptatet", "vulluptatum", "vulput", "vulputat", "vulputate", "vulpute", "wis", "wiscinim", "wisi",
                "wisis", "wisl", "wismod", "wismodi", "wismoloreet", "wisse", "xer",
            ]
        )

        return GibberishGenerator(lexicon: latinLexicon)
    }()
}
