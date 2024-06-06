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
            LineListSectionHeader(section: section, lineCount: lines.count)
        }
    }
}
