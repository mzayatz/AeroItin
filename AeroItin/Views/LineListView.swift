//
//  LineListView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 11/1/23.
//

import SwiftUI

struct LineListView: View {
    @Binding var bids: [Line]
    @Binding var lines: [Line]
    @Binding var avoids: [Line]
    @State var bookmark: Int? = nil

    let dates: [BidPeriodDate]
    let timeZone: TimeZone
    let lineHeight: CGFloat
    let transferLine: (Line, Bidpack.TransferActions, Int?) -> ()
    @Binding var selectedTripText: String?

    
    var body: some View {
        ScrollViewReader { reader in
            List {
                LineListSectionView(lines: $bids, section: .bid, lineHeight: lineHeight, dates: dates, timeZone: timeZone, transferLine: transferLine, bookmark: $bookmark, selectedTripText: $selectedTripText).listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                LineListSectionView(lines: $lines, section: .neutral, lineHeight: lineHeight, dates: dates, timeZone: timeZone, transferLine: transferLine, bookmark: $bookmark, selectedTripText: $selectedTripText).moveDisabled(true).listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                LineListSectionView(lines: $avoids, section: .avoid, lineHeight: lineHeight, dates: dates, timeZone: timeZone, transferLine: transferLine, bookmark: $bookmark, selectedTripText: $selectedTripText).listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            }
            .listStyle(.plain)
            .environment(\.defaultMinListRowHeight, lineHeight + 5)
        }
    }
}

