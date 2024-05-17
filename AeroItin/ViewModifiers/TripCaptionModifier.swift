//
//  TripCaptionModifier.swift
//  AeroItin
//
//  Created by Matt Zayatz on 5/17/24.
//

import SwiftUI

struct TripCaptionModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.background.opacity(0.5))
    }
    
}

extension View {
    func tripCaptionStyle() -> some View {
        modifier(TripCaptionModifier())
    }
}
