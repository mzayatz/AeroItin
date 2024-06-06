//
//  LineListSectionHeader.swift
//  AeroItin
//
//  Created by Matt Zayatz on 6/5/24.
//

import SwiftUI

struct LineListSectionHeader: View {
    let section: Line.Flag
    let lineCount: Int
    @Environment(BidManager.self) private var bidManager: BidManager
    
    var body: some View {
        HStack {
            Text(section == .neutral ? (bidManager.sortDescending ? "⌄ descending" : "⌃ ascending") : "").foregroundStyle(Color.accentColor)
                .onTapGesture {
                    bidManager.sortDescending.toggle()
                }
            Spacer()
            Text(sectionHeaderText)
            Spacer()
            Text("Bids").foregroundStyle(Color.accentColor)
                .onTapGesture {
                    bidManager.scrollSnap = .bid
                    bidManager.scrollNow = true
                }
            Text("Lines").foregroundStyle(Color.accentColor)
                .onTapGesture {
                    bidManager.scrollSnap = .neutral
                    bidManager.scrollNow = true
                }
            Text("Avoids").foregroundStyle(Color.accentColor)
                .onTapGesture {
                    bidManager.scrollSnap = .avoid
                    bidManager.scrollNow = true
                }
        }
        
    }
    
    var sectionHeaderText: String {
        "\(sectionTitle) " +
        "\(lineCount)"
//        (" (\(bidManager.bidpack.lines.count - bidManager.filteredLines.count) filtered)")
    }
    
    var sectionTitle: String {
        switch section {
        case .avoid:
            return "Avoids"
        case .bid:
            return "Bid"
        case .neutral:
            return "Lines"
        }
    }
}


//#Preview {
//    LineListSectionHeader()
//}
