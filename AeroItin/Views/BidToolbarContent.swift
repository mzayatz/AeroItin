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
            Button {
                showFileImporter = true
            } label: {
                Image(systemName: "doc")
            }
        }
        ToolbarItem {
            Button {
                showResetAlert = true
            } label: {
                Image(systemName: "clear").symbolRenderingMode(.monochrome).foregroundColor(.red)
            }.alert(isPresented: $showResetAlert) {
                Alert(
                    title: Text("Clear bids and avoids?"),
                    primaryButton: .cancel(),
                    secondaryButton: .destructive(Text("Clear all"), action: bidManager.resetBid)
                )
            }
        }
        ToolbarItem {
            Menu {
                Button(bidManager.bidpack.showRegularLines ? "Hide regular" : "Show regular") {
                    bidManager.bidpack.showRegularLines.toggle()
                }
                Button(bidManager.bidpack.showSecondaryLines ? "Hide secondaries" : "Show secondaries") {
                    bidManager.bidpack.showSecondaryLines.toggle()
                }
                Button(bidManager.bidpack.showReserveLines ? "Hide reserve" : "Show reserve") {
                    bidManager.bidpack.showReserveLines.toggle()
                }
            } label: {
                Image(systemName: "eye")
            }
        }
        ToolbarItem {
            Menu {
                Picker(selection: $bidManager.bidpack.sortLinesBy) {
                    ForEach(Bidpack.SortOptions.allCases, id: \.self) { Text($0.rawValue) }
                } label: {
                    Text("Sort")
                }
            } label: {
                Image(systemName: "arrow.up.arrow.down.square")
            }
        }
        ToolbarItem {
            Menu {
                Menu("Seat:  \(bidManager.bidpack.seat.rawValue)") {
                    Picker(selection:
                            $bidManager.bidpack.seat) {
                        Text(Bidpack.Seat.captain.rawValue).tag(Bidpack.Seat.captain)
                        Text(Bidpack.Seat.firstOfficer.rawValue).tag(Bidpack.Seat.firstOfficer)
                    } label: {
                        Text("Seat")
                    }
                }
            } label: {
                Image(systemName: "gear")
            }
        }
        ToolbarItem {
            NavigationLink(destination: WebViewStack()) {
                Image(systemName: "globe")
            }
        }
    }
}
