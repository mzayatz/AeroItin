//
//  LineButton.swift
//  AeroItin
//
//  Created by Matt Zayatz on 10/23/23.
//

import SwiftUI

struct LineButton: View {
    let line: Line
    let action: BidManager.TransferActions
    let transferLine: (Line, BidManager.TransferActions) -> ()
    
    var buttonImage: some View {
        switch action {
        case .fromAvoidsToBids:
            return Image(systemName: "plus.circle")
        case .fromAvoidsToLines:
            return Image(systemName: "arrow.uturn.backward.circle")
        case .fromBidsToAvoids:
            return Image(systemName: "minus.circle")
        case .fromBidsToLines:
            return Image(systemName: "arrow.uturn.backward.circle")
        case .fromLinesToAvoids:
            return Image(systemName: "minus.circle")
        case .fromLinesToBids:
            return Image(systemName: "plus.circle")
        }
    }
    
    var buttonTint: Color? {
        switch action {
        case .fromAvoidsToBids:
            return .green
        case .fromAvoidsToLines:
            return nil
        case .fromBidsToAvoids:
            return .red
        case .fromBidsToLines:
            return nil
        case .fromLinesToAvoids:
            return .red
        case .fromLinesToBids:
            return .green
        }
    }
    
    var body: some View {
        Button {
            print("swipe action fired")
            withAnimation {
                transferLine(line, action)
            }
        } label: {
            buttonImage
        }.tint(buttonTint)
    }
}

//#Preview {
//    let bidManager = BidManager(seat: .firstOfficer)
//    return LineButton(line: bidManager.bidpack.lines.randomElement()!, action: .fromLinesToBids)
//}
