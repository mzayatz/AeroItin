//
//  BidToolbarContent.swift
//  AeroItin
//
//  Created by Matt Zayatz on 11/1/23.
//

import SwiftUI

struct BidToolbarContent: ToolbarContent {
    @Binding var showFileImporter: Bool
    @Binding var showResetAlert: Bool
    @EnvironmentObject var bidManager: BidManager
    @State var showSheet = false
    
    var body: some ToolbarContent {
        ToolbarItem {
            Menu {
                Picker(selection:
                        $bidManager.bidpack.seat) {
                    Text(Bidpack.Seat.captain.rawValue).tag(Bidpack.Seat.captain)
                    Text(Bidpack.Seat.firstOfficer.rawValue).tag(Bidpack.Seat.firstOfficer)
                } label: {
                    Text("Seat")
                }
            } label: {
                Image(systemName: "chair.lounge")
            }.onChange(of: bidManager.bidpack.seat) { _ in // Deprecated iOS 17
                Task {
                    try? await bidManager.saveSettings()
                }
            }
        }
        
        ToolbarItem {
            Menu {
                Toggle("Show Regular Lines", isOn: $bidManager.bidpack.showRegularLines)
                Toggle("Show Secondary Lines", isOn: $bidManager.bidpack.showSecondaryLines)
                Toggle("Show Reserve Lines", isOn: $bidManager.bidpack.showReserveLines)
            } label: {
                Image(systemName: "line.3.horizontal.decrease")
            }
        }
        ToolbarItem {
            Menu {
                Picker(selection: $bidManager.bidpack.sortLinesBy) {
                    ForEach(Bidpack.SortOptions.allCases, id: \.self) { sortItem in
                        Button { } label: {
                            HStack {
                                Text(sortItem.rawValue)
                                Image(systemName: sortItem.symbol)
                            }
                        }
                    }
                } label: {
                    Text("Sort")
                }
            } label: {
                Image(systemName: "arrow.up.arrow.down")
            }
        }
        ToolbarItem {
            Menu {
                Button {
                    showFileImporter = true
                } label: {
                    HStack {
                        Text("Open New Bidpack")
                        Image(systemName: "doc")
                    }
                }
                
                Button(role: .destructive) {
                    showResetAlert = true
                } label: {
                    HStack {
                        Text("Clear Bids & Avoids")
                        Image(systemName: "clear")
                    }
                }
            } label: {
                Image(systemName: "folder")
            }
        }
        
        ToolbarItem {
            Spacer()
        }
    }
}
