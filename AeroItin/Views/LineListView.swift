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
                LineListSectionView(section: .bid).id("bids")
                LineListSectionView(section: .neutral).id("lines")
                LineListSectionView(section: .avoid).id("avoids")
            }
        }
        .listStyle(.plain)
    }
}

//#Preview {
//    return LineListView().environmentObject(BidManager(seat: .firstOfficer))
//}
