//
//  ContentView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 8/29/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(BidManager.self) private var bidManager: BidManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    @Environment(\.scenePhase) private var scenePhase
        
    var body: some View {
        TabView {
            TabViewLines().tabItem {
                Label("Lines", systemImage: "list.dash.header.rectangle")
            }
            TabSubmitView().tabItem {
                Label("Submit", systemImage: "globe")
            }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .inactive || phase == .background {
                Task {
                    do {
                        try await settingsManager.save()
                        try await bidManager.saveSnapshot()
                    }
                    catch {
                        fatalError(error.localizedDescription)
                    }
                }
            } 
        }
    }
}

//#Preview {
//    return ContentView(saveAction: {})
//        .environmentObject(BidManager(seat: .firstOfficer))
//}
