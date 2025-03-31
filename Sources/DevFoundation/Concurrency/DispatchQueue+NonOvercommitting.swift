//
//  DispatchQueue+NonOvercommitting.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 4/1/25.
//

import Foundation


extension DispatchQueue {
    /// Creates a new non-overcommitting dispatch queue to which work items can be submitted.
    ///
    /// - Parameters:
    ///   - label: A string label to attach to the queue to uniquely identify it in debugging tools such as Instruments,
    ///     sample, stackshots, and crash reports. Because applications, libraries, and frameworks can all create their
    ///     own dispatch queues, a reverse-DNS naming style (`com.example.myqueue`) is recommended.
    ///   - qos: The quality-of-service level to associate with the queue. This value determines the priority at which
    ///     the system schedules tasks for execution. For a list of possible values, see `DispatchQoS.QoSClass`.
    ///   - attributes: The attributes to associate with the queue. Include the `.concurrent` attribute to create a
    ///     dispatch queue that executes tasks concurrently. If you omit that attribute, the dispatch queue executes
    ///     tasks serially.
    ///   - autoreleaseFrequency: The frequency with which to autorelease objects created by the blocks that the queue
    ///     schedules. For a list of possible values, see `DispatchQueue.AutoreleaseFrequency`.
    public static func makeNonOvercommitting(
        label: String,
        qos: DispatchQoS = .unspecified,
        attributes: DispatchQueue.Attributes = [],
        autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency = .inherit
    ) -> DispatchQueue {
        return .init(
            label: label,
            qos: qos,
            attributes: attributes,
            autoreleaseFrequency: autoreleaseFrequency,
            target: .global(qos: qos.qosClass)
        )
    }
}
