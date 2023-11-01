//
//  LineButton.swift
//  AeroItin
//
//  Created by Matt Zayatz on 10/23/23.
//

import SwiftUI

struct LineButton: View {
    @EnvironmentObject var bidManager: BidManager
    let line: Line
    let action: Bidpack.TransferActions
    
    var buttonImage: some View {
        switch action {
        case .fromAvoidsToBids:
            return Image(systemName: "plus.circle").foregroundStyle(.green)
        case .fromAvoidsToLines:
            return Image(systemName: "minus.circle").foregroundStyle(.gray)
        case .fromBidsToAvoids:
            return Image(systemName: "minus.circle").foregroundStyle(.red)
        case .fromBidsToLines:
            return Image(systemName: "plus.circle").foregroundStyle(.gray)
        case .fromLinesToAvoids:
            return Image(systemName: "minus.circle").foregroundStyle(.red)
        case .fromLinesToBids:
            return Image(systemName: "plus.circle").foregroundStyle(.green)
        }
    }
    
    var body: some View {
        Button {
            withAnimation {
                bidManager.bidpack.transferLine(line: line, action: action)
            }
        } label: {
            buttonImage
        }.buttonStyle(.plain)
    }
}

#Preview {
    let bidManager = BidManager(seat: .firstOfficer)
    return LineButton(line: bidManager.bidpack.lines.randomElement()!, action: .fromLinesToBids)
}
