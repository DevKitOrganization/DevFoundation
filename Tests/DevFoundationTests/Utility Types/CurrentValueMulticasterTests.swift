//
//  CurrentValueMulticasterTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 6/30/26.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct CurrentValueMulticasterTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    // MARK: - value

    @Test
    mutating func valueReturnsInitialValue() {
        // set up a multicaster with a random initial value
        let initialValue = randomInt(in: .min ... .max)
        let multicaster = CurrentValueMulticaster(initialValue)

        // exercise / expect the getter returns the initial value
        #expect(multicaster.value == initialValue)
    }


    @Test
    mutating func settingValueUpdatesValue() {
        // set up a multicaster with a random initial value
        let multicaster = CurrentValueMulticaster(randomInt(in: .min ... .max))

        // exercise by assigning a new value
        let newValue = randomInt(in: .min ... .max)
        multicaster.value = newValue

        // expect the getter reflects the new value
        #expect(multicaster.value == newValue)
    }


    // MARK: - values()

    @Test
    mutating func valuesEmitsCurrentValueOnSubscribe() async {
        // set up a multicaster with a random initial value
        let initialValue = randomInt(in: .min ... .max)
        let multicaster = CurrentValueMulticaster(initialValue)

        // exercise by taking the first element of a fresh sequence
        var firstValue: Int?
        for await value in multicaster.values() {
            firstValue = value
            break
        }

        // expect the first element is the current value
        #expect(firstValue == initialValue)
    }


    @Test
    mutating func valuesEmitsSubsequentUpdatesInOrder() async {
        // set up an unbounded multicaster so no updates are dropped
        let initialValue = randomInt(in: .min ... .max)
        let updates = Array(count: 5) { randomInt(in: .min ... .max) }
        let multicaster = CurrentValueMulticaster(initialValue, bufferingPolicy: .unbounded)

        // exercise by subscribing, then applying every update
        let values = multicaster.values()
        for update in updates {
            multicaster.value = update
        }

        // expect the consumer observes the current value followed by every update, in order
        var received: [Int] = []
        for await value in values {
            received.append(value)
            if received.count == updates.count + 1 {
                break
            }
        }

        #expect(received == [initialValue] + updates)
    }


    @Test
    mutating func lateSubscriberReceivesLatestValueThenFutureUpdates() async {
        // set up an unbounded multicaster and apply several updates before subscribing
        let initialValue = randomInt(in: .min ... .max)
        let earlyUpdates = Array(count: 3) { randomInt(in: .min ... .max) }
        let multicaster = CurrentValueMulticaster(initialValue, bufferingPolicy: .unbounded)
        for update in earlyUpdates {
            multicaster.value = update
        }

        // exercise by subscribing late, then applying one more update
        let values = multicaster.values()
        let laterUpdate = randomInt(in: .min ... .max)
        multicaster.value = laterUpdate

        // expect the late subscriber sees the most recent value first, then the future update
        var received: [Int] = []
        for await value in values {
            received.append(value)
            if received.count == 2 {
                break
            }
        }

        #expect(received == [earlyUpdates.last, laterUpdate])
    }


    @Test
    mutating func updateAfterSubscribeBeforeFirstPullIsNotLost() async {
        // set up the motivating race: subscribe, then update before the first pull
        let initialValue = randomInt(in: .min ... .max)
        let newValue = randomInt(in: .min ... .max)

        // with an unbounded policy, both the value-at-subscribe and the update are observed in order
        let unboundedMulticaster = CurrentValueMulticaster(initialValue, bufferingPolicy: .unbounded)
        let unboundedValues = unboundedMulticaster.values()
        unboundedMulticaster.value = newValue

        var unboundedReceived: [Int] = []
        for await value in unboundedValues {
            unboundedReceived.append(value)
            if unboundedReceived.count == 2 {
                break
            }
        }

        #expect(unboundedReceived == [initialValue, newValue])

        // with the default newest-1 policy, the update is still observed — it is never lost
        let newestMulticaster = CurrentValueMulticaster(initialValue)
        let newestValues = newestMulticaster.values()
        newestMulticaster.value = newValue

        var newestFirstValue: Int?
        for await value in newestValues {
            newestFirstValue = value
            break
        }

        #expect(newestFirstValue == newValue)
    }


    @Test
    mutating func multipleConsumersEachReceiveEveryUpdate() async {
        // set up an unbounded multicaster and subscribe several consumers up front
        let initialValue = randomInt(in: .min ... .max)
        let updates = Array(count: 4) { randomInt(in: .min ... .max) }
        let expectedValues = [initialValue] + updates
        let multicaster = CurrentValueMulticaster(initialValue, bufferingPolicy: .unbounded)

        let consumerCount = 3
        let sequences = (0 ..< consumerCount).map { _ in multicaster.values() }

        // exercise by applying every update after all consumers have subscribed
        for update in updates {
            multicaster.value = update
        }

        // expect every consumer observes the current value followed by every update, in order
        for sequence in sequences {
            var received: [Int] = []
            for await value in sequence {
                received.append(value)
                if received.count == expectedValues.count {
                    break
                }
            }

            #expect(received == expectedValues)
        }
    }


    // MARK: - Lifetime

    @Test
    mutating func deallocatingMulticasterFinishesConsumerStreams() async {
        // set up a multicaster referenced only by a local optional
        let initialValue = randomInt(in: .min ... .max)
        var multicaster: CurrentValueMulticaster? = CurrentValueMulticaster(initialValue)

        // subscribe a consumer that counts the values it receives before its stream finishes
        let values = multicaster!.values()
        let consumer = Task {
            var receivedCount = 0
            for await _ in values {
                receivedCount += 1
            }
            return receivedCount
        }

        // exercise by releasing the only strong reference to the multicaster
        multicaster = nil

        // expect the consumer’s stream finishes after delivering the buffered current value
        let receivedCount = await consumer.value
        #expect(receivedCount == 1)
    }


    // MARK: - Buffering policy

    @Test
    mutating func bufferingNewestKeepsLatestValue() async {
        // set up a newest-1 multicaster and subscribe before applying updates
        let initialValue = randomInt(in: .min ... .max)
        let updates = Array(count: 3) { randomInt(in: .min ... .max) }
        let multicaster = CurrentValueMulticaster(initialValue, bufferingPolicy: .bufferingNewest(1))

        // exercise by applying every update without consuming, so only the newest is retained
        let values = multicaster.values()
        for update in updates {
            multicaster.value = update
        }

        // expect the first value the slow consumer pulls is the most recent
        var firstValue: Int?
        for await value in values {
            firstValue = value
            break
        }

        #expect(firstValue == updates.last)
    }


    @Test
    mutating func unboundedBuffersAllValues() async {
        // set up an unbounded multicaster and subscribe before applying updates
        let initialValue = randomInt(in: .min ... .max)
        let updates = Array(count: 3) { randomInt(in: .min ... .max) }
        let multicaster = CurrentValueMulticaster(initialValue, bufferingPolicy: .unbounded)

        // exercise by applying every update without consuming
        let values = multicaster.values()
        for update in updates {
            multicaster.value = update
        }

        // expect the slow consumer pulls every value in order
        var received: [Int] = []
        for await value in values {
            received.append(value)
            if received.count == updates.count + 1 {
                break
            }
        }

        #expect(received == [initialValue] + updates)
    }


    @Test
    mutating func bufferingOldestKeepsEarliestValues() async {
        // set up an oldest-2 multicaster and subscribe before applying updates
        let initialValue = randomInt(in: .min ... .max)
        let updates = Array(count: 3) { randomInt(in: .min ... .max) }
        let multicaster = CurrentValueMulticaster(initialValue, bufferingPolicy: .bufferingOldest(2))

        // exercise by applying every update without consuming, so only the oldest two are retained
        let values = multicaster.values()
        for update in updates {
            multicaster.value = update
        }

        // expect the slow consumer pulls the current value and the first update, in order
        var received: [Int] = []
        for await value in values {
            received.append(value)
            if received.count == 2 {
                break
            }
        }

        #expect(received == [initialValue, updates.first])
    }
}
