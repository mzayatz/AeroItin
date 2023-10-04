//
//  TripTextView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 9/26/23.
//

import SwiftUI

struct TripTextView: View {
    
    @Binding var selectedTripText: String?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5.0).foregroundStyle(.regularMaterial)
            RoundedRectangle(cornerRadius: 5.0).stroke(lineWidth: 1.0)
            VStack {
                Text(selectedTripText ?? "")
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .padding()
                Button("dismiss") {
                    withAnimation {
                        selectedTripText = nil
                    }
                }.padding()
            }
        }.frame(width: 800)
            .fixedSize(horizontal: false, vertical: true)
            .zIndex(2)
    }
}

struct TripTextView_Previews: PreviewProvider {
    static var previews: some View {
        TripTextView(selectedTripText: Binding.constant("test"))
    }
}
