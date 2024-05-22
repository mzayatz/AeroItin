//
//  LineListSectionView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 10/23/23.
//

import SwiftUI

struct LineListSectionView: View {
    @Binding var lines: [Line]
    let section: Line.Flag
    let lineHeight: CGFloat
    let dates: [BidPeriodDate]
    let timeZone: TimeZone
    @State var sortDescending = false
    let transferLine: (Line, Bidpack.TransferActions, Int?) -> ()
    @Binding var bookmark: Int?
    @Binding var selectedTripText: String?

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
    let sectionHeaderText = "Placeholder Text"
    //    var sectionHeaderText: String {
    //        "\(sectionTitle) " +
    //        "\(section != .neutral ? bidManager.bidpack[keyPath: section.associatedArrayKeypath].count : bidManager.filteredLines.count)" +
    //        (section != .neutral ? "" : " (\(bidManager.bidpack.lines.count - bidManager.filteredLines.count) filtered)")
    //    }
    
    var body: some View {
        Section {
            ForEach(lines) { line in
                LineView(line: line, section: section, dates: dates, timeZone: timeZone, selectedTripText: $selectedTripText)
                    .frame(height: lineHeight)
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        LineButton(line: line, action: section.plusTransferAction, transferLine: transferLine, destinationIndex: $bookmark)
                        if(section == .bid) {
                            Button {
                                withAnimation {
                                    lines.moveElementToIndex(element: line, index: bookmark ?? lines.startIndex)
                                }
                            } label: {
                                Image(systemName: "point.topleft.down.to.point.bottomright.curvepath.fill")
                            }.tint(.yellow)
                            Button {
                                bookmark = lines.firstIndex(of: line) ?? 0
                            } label: {
                                Image(systemName: "bookmark.square")
                            }.tint(.blue)
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        LineButton(line: line, action: section.minusTransferAction, transferLine: transferLine, destinationIndex: $bookmark)
                    }
            }.onMove {
                lines.move(fromOffsets: $0, toOffset: $1)
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
