//
//  LineListView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 11/1/23.
//

import SwiftUI

struct LineListView: View {
    let xxLineHeight: CGFloat = 25
    
    var body: some View {
        ScrollViewReader { reader in
            List {
                LineListSectionView(section: .bid).id("bids").listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                LineListSectionView(section: .neutral).id("lines").moveDisabled(true).listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                LineListSectionView(section: .avoid).id("avoids").listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            }
            .listStyle(.plain)
            .environment(\.defaultMinListRowHeight, xxLineHeight + 5)
        }
    }
}

