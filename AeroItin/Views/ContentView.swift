//
//  ContentView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 8/29/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var bidManager: BidManager
    var body: some View {
        TabView {
            LinesTabView().tabItem {
                Label("Lines", systemImage: "list.dash.header.rectangle")
            }
        }
    }
}

#Preview {
    return ContentView().environmentObject(BidManager(seat: .firstOfficer))
}
