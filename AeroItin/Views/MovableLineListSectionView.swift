//
//  LineListSectionView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 10/23/23.
//

import SwiftUI

struct MovableLineListSectionView: View {
    @Binding var lines: [Line]
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
        sectionTitle  + " " + String(lines.count)
    }
    
    var body: some View {
        @Bindable var bidManager = bidManager
        Section {
            ForEach(lines) { line in
                LineView(line: line, section: section, dates: bidManager.bidpack.dates, timeZone: bidManager.bidpack.base.timeZone)
                    .frame(height: lineHeight)
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        LineButton(line: line, action: section.plusTransferAction, transferLine: bidManager.transferLine)
                        if(section == .bid) {
                            Button {
                                withAnimation {
                                    lines.moveElementToIndex(element: line, index: bidManager.bookmark ?? lines.startIndex)
                                    if let bookmark = bidManager.bookmark { bidManager.bookmark = bookmark + 1 }
                                }
                            } label: {
                                Image(systemName: "point.topleft.down.to.point.bottomright.curvepath.fill")
                            }.tint(.yellow)
                            Button {
                                let newBookmark = lines.firstIndex(of: line) ?? 0
                                if newBookmark == bidManager.bookmark {
                                    bidManager.bookmark = nil
                                } else {
                                    bidManager.bookmark = newBookmark
                                }
                            } label: {
                                Image(systemName: "bookmark.square")
                            }.tint(.blue)
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        LineButton(line: line, action: section.minusTransferAction, transferLine: bidManager.transferLine)
                    }
            }.onMove {
                lines.move(fromOffsets: $0, toOffset: $1)
            }
        } header: {
            HStack {
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
