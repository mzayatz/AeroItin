//
//  AeroItinApp.swift
//  AeroItin
//
//  Created by Matt Zayatz on 8/29/23.
//

import SwiftUI

@main
struct AeroItinApp: App {
    @StateObject var bidManager = BidManager()
    @StateObject var settingsManager = SettingsManager()
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bidManager)
                .environmentObject(settingsManager)
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
