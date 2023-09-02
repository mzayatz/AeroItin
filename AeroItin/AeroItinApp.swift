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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
