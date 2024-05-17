//
//  TripCaptionView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 5/17/24.
//

import SwiftUI

struct TripCaptionView: View {
    let number: String
    let description: String
    let isRfo: Bool
    
    var body: some View {
        VStack(spacing: 2) {
            Text(number).tripCaptionStyle()
            Text(description).tripCaptionStyle()
        }
        .padding(1.5)
        .font(isRfo ? .caption2.italic() : .caption2)
        .underline(isRfo)
    }
}

#Preview {
    TripCaptionView(number: "1", description: "EWR-BLV", isRfo: false)
}
