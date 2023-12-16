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
            TabViewLines().tabItem {
                Label("Lines", systemImage: "list.dash.header.rectangle")
            }
            SubmitBidView().tabItem {
                Label("Submit", systemImage: "globe")
            }
            TabSettingsView().tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
    }
}

#Preview {
    return ContentView().environmentObject(BidManager(seat: .firstOfficer))
}
