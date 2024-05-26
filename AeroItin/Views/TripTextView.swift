//
//  TripTextView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 9/26/23.
//

import SwiftUI

struct TripTextView: View {
    
    //    @GestureState var offset = CGSize()
    @Environment(BidManager.self) private var bidManager: BidManager
    
    let font: Font = .system(size: 12, weight: .regular, design: .monospaced)
    let largerFont: Font = .system(size: 12, weight: .bold, design: .monospaced)
    var body: some View {
        @Bindable var bidManager = bidManager
        ZStack {
            RoundedRectangle(cornerRadius: 5.0).foregroundStyle(.regularMaterial)
            RoundedRectangle(cornerRadius: 5.0).stroke(lineWidth: 1.0)
            VStack {
                Text(attText ?? "")
                    .font(font)
                    .padding(EdgeInsets(top: 20, leading: 20, bottom: 5, trailing: 20))
                Button("dismiss") {
                    bidManager.showTripText = false
                }.padding(.bottom)
            }
        }.frame(width: 800)
            .fixedSize(horizontal: false, vertical: true)
            .zIndex(2)
            .onTapGesture(count: 2) {
                bidManager.showTripText = false
            }
    }
    
    var attText: AttributedString? {
        guard let tripText = bidManager.selectedTripText else {
            return nil
        }
        var attributedTripText = AttributedString(tripText)
        
        for match in tripText.attributedRanges(of: /.*\b(\w\w)?\d\d\d\d *\b\w\w\w *\b[A-Z]{3}\b(?= \d\d\d\d).*/, using: attributedTripText) {
            attributedTripText[match].font = largerFont
        }
        
        //        for match in tripText.attributedRanges(of: /\b\w\w\d\d\d\d\b/, using: attributedTripText) {
        //            attributedTripText[match].foregroundColor = .accentColor
        //            attributedTripText[match].font = font.bold()
        //
        //        }
        //        for match in tripText.attributedRanges(of: /\b[A-Z]{3}\b(?= \d\d\d\d)/, using: attributedTripText) {
        //            attributedTripText[match].foregroundColor = .accentColor
        //            attributedTripText[match].font = font.bold()
        //        }
        
        
        return attributedTripText
    }
}

struct TripTextView_Previews: PreviewProvider {
    static var previews: some View {
        TripTextView()
    }
}

extension String {
    func attributedRanges(of regex: some RegexComponent, using attributedString: AttributedString) -> [Range<AttributedString.Index>] {
        return self.ranges(of: regex).compactMap { Range<AttributedString.Index>.init($0, in: attributedString) }
    }
}
