//
//  LineListView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 11/1/23.
//

import SwiftUI

struct LineListView: View {
    @EnvironmentObject var bidManager: BidManager
    var body: some View {
        ScrollViewReader { reader in
            List {
                LineListSectionView(section: .bid).id("bids").listRowInsets(.init())
                LineListSectionView(section: .neutral).id("lines").moveDisabled(true).listRowInsets(.init())
                LineListSectionView(section: .avoid).id("avoids").listRowInsets(.init())
            }
            .listStyle(.plain)
            .environment(\.defaultMinListRowHeight, bidManager.lineHeight + 5)
        }
    }
}

//#Preview {
//    return LineListView().environmentObject(BidManager(seat: .firstOfficer))
//}
