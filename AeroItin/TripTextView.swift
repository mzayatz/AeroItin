//
//  TripTextView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 9/26/23.
//

import SwiftUI

struct TripTextView: View {
    
    let text: String
    
    var body: some View {
        ScrollView {
            Text(text).font(.caption2).monospaced()
                .padding()
        }
    }
}

struct TripTextView_Previews: PreviewProvider {
    static var previews: some View {
        TripTextView(text: "Test")
    }
}
