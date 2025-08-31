//
//  HostIsOneOfTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/31/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct HostIsOneOfTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initSetsHosts() {
        let hosts = Set(count: randomInt(in: 3 ... 5)) { randomAlphanumericString() }
        let condition = SimulatedURLRequestLoader.RequestConditions.HostIsOneOf(hosts: hosts)

        #expect(condition.hosts == hosts)
    }


    @Test
    mutating func isFulfilledReturnsTrueWhenHostMatches() {
        let hosts = Set(count: randomInt(in: 3 ... 5)) { randomAlphanumericString() }

        let condition = SimulatedURLRequestLoader.RequestConditions.HostIsOneOf(hosts: hosts)
        let url = URL(string: "https://\(randomElement(in: hosts)!)/users")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HTTPMethod.get.rawValue
        let requestComponents = SimulatedURLRequestLoader.RequestComponents(urlRequest: urlRequest)!

        #expect(condition.isFulfilled(by: requestComponents))
    }


    @Test
    mutating func isFulfilledReturnsFalseWhenHostDoesNotMatch() {
        let hosts = Set(count: randomInt(in: 3 ... 5)) { randomAlphanumericString() }

        let condition = SimulatedURLRequestLoader.RequestConditions.HostIsOneOf(hosts: hosts)
        let url = URL(string: "https://\(randomAlphanumericString(count: 10))/users")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HTTPMethod.get.rawValue
        let requestComponents = SimulatedURLRequestLoader.RequestComponents(urlRequest: urlRequest)!

        #expect(!condition.isFulfilled(by: requestComponents))
    }


    @Test
    mutating func descriptionReturnsExpectedFormat() {
        let hosts = Set(count: randomInt(in: 3 ... 5)) { randomAlphanumericString() }
        let condition = SimulatedURLRequestLoader.RequestConditions.HostIsOneOf(hosts: hosts)

        #expect(String(describing: condition) == ".host(isOneOf: \(hosts))")
    }


    @Test
    mutating func hostEqualsCreatesConditionWithSingleHost() {
        let host = randomAlphanumericString()
        let condition: SimulatedURLRequestLoader.RequestConditions.HostIsOneOf = .hostEquals(host)

        #expect(condition.hosts == [host])
    }


    @Test
    mutating func hostIsOneOfCreatesConditionWithMultipleHosts() {
        let hosts = Set(count: randomInt(in: 3 ... 5)) { randomAlphanumericString() }
        let condition: SimulatedURLRequestLoader.RequestConditions.HostIsOneOf = .host(isOneOf: hosts)

        #expect(condition.hosts == hosts)
    }
}
