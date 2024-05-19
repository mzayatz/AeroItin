//
//  LineListSectionView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 10/23/23.
//

import SwiftUI

struct LineListSectionView: View {
    @EnvironmentObject var bidManager: BidManager
    let section: Line.Flag
    
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
        "\(section != .neutral ? bidManager.bidpack[keyPath: section.associatedArrayKeypath].count : bidManager.filteredLines.count)" +
        (section != .neutral ? "" : " (\(bidManager.bidpack.lines.count - bidManager.filteredLines.count) filtered)")
    }
    
    var body: some View {
        if(!bidManager.bidpack[keyPath: section.associatedArrayKeypath].isEmpty) {
            Section {
                ForEach(section != .neutral ? bidManager.bidpack[keyPath: section.associatedArrayKeypath] : bidManager.filteredLines) { line in
                        LineView(line: line, section: section)
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            LineButton(line: line, action: section.plusTransferAction)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            LineButton(line: line, action: section.minusTransferAction)
                        }
                }.onMove {
                    bidManager.bidpack[keyPath: section.associatedArrayKeypath].move(fromOffsets: $0, toOffset: $1)
                }
            } header: {
                HStack {
                    Text(bidManager.bidpack.sortDescending ? "⌄ descending" : "⌃ ascending").foregroundStyle(Color.accentColor)
                        .onTapGesture {
                            bidManager.bidpack.sortDescending.toggle()
                        }
                    Spacer()
                    Text(sectionHeaderText)
                    Spacer()
                    Text("Bids").foregroundStyle(Color.accentColor)
                        .onTapGesture {
                            bidManager.scrollSnap = .bid
                        }
                    Text("Lines").foregroundStyle(Color.accentColor)
                        .onTapGesture {
                            bidManager.scrollSnap = .neutral
                        }
                    Text("Avoids").foregroundStyle(Color.accentColor)
                        .onTapGesture {
                            bidManager.scrollSnap = .avoid
                        }
                }
                
            }
        }
    }
}

//#Preview {
//    let bidManager = BidManager(seat: .firstOfficer)
//    return List { LineListSectionView(section: .neutral).environmentObject(bidManager) }
//}
