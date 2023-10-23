//
//  TripTextView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 9/26/23.
//

import SwiftUI

struct TripTextView: View {
    
    @Binding var selectedTripText: String?
    
    let font: Font = .system(size: 12, weight: .regular, design: .monospaced)
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5.0).foregroundStyle(.regularMaterial)
            RoundedRectangle(cornerRadius: 5.0).stroke(lineWidth: 1.0)
            VStack {
                Text(attText ?? "")
                    .font(font)
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
    
    var attText: AttributedString? {
        guard let tripText = selectedTripText else {
            return nil
        }
        var attributedTripText = AttributedString(tripText)
        
        for match in tripText.attributedRanges(of: /\b\w\w\d\d\d\d\b/, using: attributedTripText) {
            attributedTripText[match].foregroundColor = .accentColor
            attributedTripText[match].font = font.bold()

        }
        for match in tripText.attributedRanges(of: /\b[A-Z]{3}\b(?= \d\d\d\d)/, using: attributedTripText) {
            attributedTripText[match].foregroundColor = .accentColor
            attributedTripText[match].font = font.bold()

        }
        return attributedTripText
    }
}

struct TripTextView_Previews: PreviewProvider {
    static var previews: some View {
        TripTextView(selectedTripText: Binding.constant("test"))
    }
}

extension String {
    func attributedRanges(of regex: some RegexComponent, using attributedString: AttributedString) -> [Range<AttributedString.Index>] {
        return self.ranges(of: regex).compactMap { Range<AttributedString.Index>.init($0, in: attributedString) }
    }
}
