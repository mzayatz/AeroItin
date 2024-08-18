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
                                    lines.moveElementToIndex(element: line, index: lines.startIndex)
                                }
                            } label: {
                                Image(systemName: "arrow.up.to.line.compact")
                            }
                            Button {
                                withAnimation {
                                    lines.moveElementToIndex(element: line, index: lines.endIndex)
                                }
                            } label: {
                                Image(systemName: "arrow.down.to.line.compact")
                            }
                            Button {
                                withAnimation {
                                    if let bookmarkIndex = bidManager.bookmarkIndex {
                                        lines.moveElementToIndex(element: line, index: bookmarkIndex)
                                    }
                                }
                            } label: {
                                Image(systemName: "point.topleft.down.to.point.bottomright.curvepath.fill")
                            }.tint(.yellow)
                            Button {
                                let newBookmark = line
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
            LineListSectionHeader(section: section, lineCount: lines.count)
        }
    }
}
