//
//  Color+random.swift
//  AeroItin
//
//  Created by Matt Zayatz on 5/22/24.
//

import Foundation
import SwiftUI

extension Color {
    static var random: Color {
        [
            Color.gray,
            Color.blue,
            Color.red,
            Color.green,
            Color.yellow,
            Color.orange,
            Color.brown,
            Color.cyan,
            Color.indigo,
            Color.mint,
            Color.pink,
            Color.purple,
            Color.teal
        ].randomElement()!
    }
}
