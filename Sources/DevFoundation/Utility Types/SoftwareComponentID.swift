//
//  SoftwareComponentID.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/13/25.
//

import Foundation


/// A reverse-DNS identifier for a software component.
///
/// The term _software component_ is intentionally vaguely defined. It could be a function, type, subsystem, module or
/// package, application, etc. It could even be a user interface element.
///
/// Software component IDs are a type of ``DottedHierarchicalID``. You can uses its API to create a hierarchy of
/// component IDs as follows:
///
///     let spacely = SoftwareComponentID("com.spacely")
///
///     let sprockets = spacely.appending("sprockets")
///     let sprocketsAuthentication = sprockets.appending("authentication")
///
///     let widgets = spacely.appending("widgets")
///     let checkout = widgets.appending("checkout")
///     let checkoutButton = checkout.appending("checkoutButton")
public struct SoftwareComponentID: Codable, DottedHierarchicalID, TypedExtensibleEnum {
    public let rawValue: String


    public init(_ rawValue: String) {
        self.rawValue = Self.rawValueOmittingEmptyComponents(rawValue)
    }
}
