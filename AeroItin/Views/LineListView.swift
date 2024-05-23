//
//  LineListView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 11/1/23.
//

import SwiftUI

struct LineListView: View {
    @Binding var bids: [Line]
    let lines: [Line]
    @Binding var avoids: [Line]
    @State var bookmark: Int? = nil
    @Environment(\.lineHeight) var lineHeight
    
    let dates: [BidPeriodDate]
    let timeZone: TimeZone
    let transferLine: (Line, Bidpack.TransferActions, Int?) -> ()
    @Binding var selectedTripText: String?
    @Binding var sortDescending: Bool
    
    var body: some View {
        ScrollViewReader { reader in
            List {
                MovableLineListSectionView(lines: $bids, section: .bid, dates: dates, timeZone: timeZone, transferLine: transferLine, bookmark: $bookmark, selectedTripText: $selectedTripText).listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                LineListSectionView(lines: lines, section: .neutral, dates: dates, timeZone: timeZone, transferLine: transferLine, bookmark: $bookmark, selectedTripText: $selectedTripText, sortDescending: $sortDescending).moveDisabled(true).listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                MovableLineListSectionView(lines: $avoids, section: .avoid, dates: dates, timeZone: timeZone, transferLine: transferLine, bookmark: $bookmark, selectedTripText: $selectedTripText).listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            }
            .listStyle(.plain)
            .environment(\.defaultMinListRowHeight, lineHeight + 5)
        }
    }
}

