//
//  EnvironmentKey+UIProperties.swift
//  AeroItin
//
//  Created by Matt Zayatz on 5/22/24.
//

import Foundation
import SwiftUI

struct LineHeightKey: EnvironmentKey {
    static let defaultValue: CGFloat = 35.0
}

extension EnvironmentValues {
    public var lineHeight: CGFloat {
        get { self[LineHeightKey.self] }
        set { self[LineHeightKey.self] = newValue }
    }
}
