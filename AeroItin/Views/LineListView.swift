//
//  LineListView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 11/1/23.
//

import SwiftUI

struct LineListView: View {
    @Environment(\.lineHeight) var lineHeight
    @Environment(BidManager.self) private var bidManager: BidManager
    
    
    var body: some View {
        @Bindable var bidManager = bidManager
        List {
            if !bidManager.bidpack.bids.isEmpty {
                MovableLineListSectionView(lines: $bidManager.bidpack.bids, section: .bid).listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            }
            LineListSectionView(lines: bidManager.filteredLines, section: .neutral).moveDisabled(true).listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            if !bidManager.bidpack.avoids.isEmpty {
                MovableLineListSectionView(lines: $bidManager.bidpack.avoids, section: .avoid).listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            }
        }
        .listStyle(.plain)
        .environment(\.defaultMinListRowHeight, lineHeight + 5)
    }
}

