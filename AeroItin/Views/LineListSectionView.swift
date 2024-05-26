//
//  LineListSectionView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 10/23/23.
//

import SwiftUI

struct LineListSectionView: View {
    let lines: [Line]
    let section: Line.Flag
    @Environment(\.lineHeight) var lineHeight
    @Environment(BidManager.self) private var bidManager: BidManager

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
    var sectionHeaderText: String {
        "\(sectionTitle) " +
        "\(lines.count)" 
//        (" (\(bidManager.bidpack.lines.count - bidManager.filteredLines.count) filtered)")
    }
    
    var body: some View {
        @Bindable var bidManager = bidManager
        Section {
            ForEach(lines) { line in
                LineView(line: line, section: section, dates: bidManager.bidpack.dates, timeZone: bidManager.bidpack.base.timeZone)
                    .frame(height: lineHeight)
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        LineButton(line: line, action: section.plusTransferAction, transferLine: bidManager.transferLine)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        LineButton(line: line, action: section.minusTransferAction, transferLine: bidManager.transferLine)
                    }
            }
        } header: {
            HStack {
                Text(section == .neutral ? (bidManager.sortDescending ? "⌄ descending" : "⌃ ascending") : "").foregroundStyle(Color.accentColor)
                    .onTapGesture {
                        bidManager.sortDescending.toggle()
                    }
                Spacer()
                Text(sectionHeaderText)
                Spacer()
                Text("Bids").foregroundStyle(Color.accentColor)
//                    .onTapGesture {
//                        bidManager.scrollSnap = .bid
//                        bidManager.scrollNow = true
//                    }
                Text("Lines").foregroundStyle(Color.accentColor)
//                    .onTapGesture {
//                        bidManager.scrollSnap = .neutral
//                        bidManager.scrollNow = true
//                    }
                Text("Avoids").foregroundStyle(Color.accentColor)
//                    .onTapGesture {
//                        bidManager.scrollSnap = .avoid
//                        bidManager.scrollNow = true
//                    }
            }
            
        }
    }
}
