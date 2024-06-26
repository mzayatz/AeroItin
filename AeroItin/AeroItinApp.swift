//
//  AeroItinApp.swift
//  AeroItin
//
//  Created by Matt Zayatz on 8/29/23.
//

import SwiftUI

@main
struct AeroItinApp: App {
    @State var bidManager = BidManager()
    @StateObject var settingsManager = SettingsManager()
    @StateObject private var webViewModel = WebViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(bidManager)
                .environmentObject(settingsManager)
                .environmentObject(webViewModel)
                .task {
                    do {
                        try await settingsManager.load()
                    } catch {
                        do {
                            try await settingsManager.save()
                        } catch {
                            fatalError(error.localizedDescription)
                        }
                    }
                    
                    do {
                        try await bidManager.loadSnapshot()
                    } catch {
                        do {
                            try await bidManager.saveSnapshot()
                        } catch {
                            fatalError(error.localizedDescription)
                        }
                    }
                }
        }
    }
}
