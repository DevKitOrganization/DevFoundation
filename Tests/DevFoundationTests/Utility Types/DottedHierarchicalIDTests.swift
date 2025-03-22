//
//  DottedHierarchicalIDTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/13/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing


struct DottedHierarchicalIDTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    func rawValueOmittingEmptyComponentsOmitsEmptyComponents() {
        let rawValue = "...a....b....c.....d.e..f.."
        #expect(MockID.rawValueOmittingEmptyComponents(rawValue) == "a.b.c.d.e.f")
    }


    @Test
    mutating func isAncestorReturnsFalseForEmptyID() throws {
        let emptyID = try #require(MockID(rawValue: ""))
        for _ in 0 ..< 10 {
            let other = try #require(MockID(rawValue: randomRawValue()))
            #expect(!emptyID.isAncestor(of: other))
        }
    }


    @Test
    mutating func isAncestorFunctionsReturnsTrueWhenIDsShareCommonPrefix() throws {
        let rawValue = randomRawValue()
        let components = rawValue.split(separator: ".")

        let id = try #require(MockID(rawValue: rawValue))

        for count in 1 ..< components.count {
            let ancestorComponents = components[0 ..< count].joined(separator: ".")
            let ancestor = try #require(MockID(rawValue: ancestorComponents))
            #expect(ancestor.isAncestor(of: id))
            #expect(id.isDescendent(of: ancestor))

            let lowestAncestor1 = try #require(ancestor.lowestCommonAncestor(with: id))
            #expect(lowestAncestor1 == ancestor)
            let lowestAncestor2 = try #require(id.lowestCommonAncestor(with: ancestor))
            #expect(lowestAncestor2 == ancestor)
        }
    }


    @Test
    mutating func lowestCommonAncestorWithUncommonSuffix() throws {
        let prefix = randomRawValue()
        let suffix1 = randomRawValue()
        let suffix2 = randomRawValue()

        let ancestor = try #require(MockID(rawValue: prefix))
        let id1 = try #require(MockID(rawValue: "\(prefix).\(suffix1)"))
        let id2 = try #require(MockID(rawValue: "\(prefix).\(suffix2)"))

        let lowestAncestor1 = try #require(id1.lowestCommonAncestor(with: id2))
        #expect(lowestAncestor1 == ancestor)
        let lowestAncestor2 = try #require(id2.lowestCommonAncestor(with: id1))
        #expect(lowestAncestor2 == ancestor)
    }


    @Test
    mutating func isAncestorFunctionsReturnFalseWhenIDsHaveNoCommonPrefix() throws {
        for _ in 1 ..< 10 {
            let id1 = try #require(MockID(rawValue: randomRawValue()))
            let id2 = try #require(MockID(rawValue: randomRawValue()))

            #expect(!id1.isAncestor(of: id2))
            #expect(!id2.isDescendent(of: id1))
            #expect(id1.lowestCommonAncestor(with: id2) == nil)
            #expect(id2.lowestCommonAncestor(with: id1) == nil)
        }
    }


    @Test
    mutating func appendingFunctions() throws {
        let rawValue1 = randomRawValue()
        let rawValue2 = randomRawValue()

        let id1 = try #require(MockID(rawValue: rawValue1))
        let id2 = try #require(MockID(rawValue: rawValue2))

        let id1AndID2 = try #require(id1.appending(id2))
        #expect(id1AndID2.rawValue == "\(rawValue1).\(rawValue2)")

        let id1AndID2String = try #require(id1.appending(".....\(rawValue2)....."))
        #expect(id1AndID2String.rawValue == "\(rawValue1).\(rawValue2)")
    }


    @Test
    mutating func appendingStringWithNilID() throws {
        let id = try #require(MockID(rawValue: randomRawValue()))
        #expect(id.appending("disallowed") == nil)
    }


    @Test
    mutating func appendingFunctionsWithTypedExtensibleEnum() {
        let rawValue1 = randomRawValue()
        let rawValue2 = randomRawValue()

        let id1 = MockTypedExtensibleID(rawValue1)
        let id2 = MockTypedExtensibleID(rawValue2)

        #expect(id1.appending(id2).rawValue == "\(rawValue1).\(rawValue2)")
        #expect(id1.appending(".......\(rawValue2).......").rawValue == "\(rawValue1).\(rawValue2)")
    }


    private mutating func randomRawValue() -> String {
        Array(count: random(Int.self, in: 3 ... 5)) {
            randomAlphanumericString()
        }.joined(separator: ".")
    }
}


private struct MockID: DottedHierarchicalID {
    let rawValue: String


    init?(rawValue: String) {
        guard rawValue != "disallowed" else {
            return nil
        }

        self.rawValue = Self.rawValueOmittingEmptyComponents(rawValue)
    }
}


private struct MockTypedExtensibleID: DottedHierarchicalID, TypedExtensibleEnum {
    let rawValue: String


    init(_ rawValue: String) {
        self.rawValue = Self.rawValueOmittingEmptyComponents(rawValue)
    }
}
