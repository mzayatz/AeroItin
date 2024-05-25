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
    let dates: [BidPeriodDate]
    let timeZone: TimeZone
    let transferLine: (Line, BidManager.TransferActions) -> ()
    @Binding var bookmark: Int?
    @Binding var selectedTripText: String?
    @Binding var sortDescending: Bool

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
        Section {
            ForEach(lines) { line in
                LineView(line: line, section: section, dates: dates, timeZone: timeZone, selectedTripText: $selectedTripText)
                    .frame(height: lineHeight)
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        LineButton(line: line, action: section.plusTransferAction, transferLine: transferLine)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        LineButton(line: line, action: section.minusTransferAction, transferLine: transferLine)
                    }
            }
        } header: {
            HStack {
                Text(section == .neutral ? (sortDescending ? "⌄ descending" : "⌃ ascending") : "").foregroundStyle(Color.accentColor)
                    .onTapGesture {
                        sortDescending.toggle()
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
