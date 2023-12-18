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
    
    @Environment(\.scenePhase) private var scenePhase
    
    let saveAction: () -> Void
    
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
        .onChange(of: scenePhase) { phase in
            if phase == .inactive {
                saveAction()
            }
        }
    }
}

#Preview {
    return ContentView(saveAction: {})
        .environmentObject(BidManager(seat: .firstOfficer))
}
