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
    let testing = true
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(bidManager)
                .task {
                    do {
                        try await bidManager.loadSettings()
                        if testing {
                            try await bidManager.loadBidpackWithString(String(contentsOf: BidManager.testingUrl))
                        }
                    } catch {
                        do {
                            try await bidManager.saveSettings()
                        } catch {
                            fatalError(error.localizedDescription)
                        }
                    }
                }
        }
    }
}
