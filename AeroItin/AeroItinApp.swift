//
//  AeroItinApp.swift
//  AeroItin
//
//  Created by Matt Zayatz on 8/29/23.
//

import SwiftUI

@main
struct AeroItinApp: App {
    @StateObject var bidManager = BidManager(seat: .firstOfficer)
    var body: some Scene {
        WindowGroup {
            ContentView(saveAction: {
                Task {
                    do {
                        try await bidManager.saveSettings()
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
            }).environmentObject(bidManager)
                .task {
                    do {
                        try await bidManager.loadSettings()
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
        }
    }
}
