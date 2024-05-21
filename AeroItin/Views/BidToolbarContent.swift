//
//  BidToolbarContent.swift
//  AeroItin
//
//  Created by Matt Zayatz on 11/1/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct BidToolbarContent: ToolbarContent {
    @State var showAscFileImporter = false
    @State var showSavedBidImporter = false
    @State var showSavedBidExporter = false
    @Binding var showResetAlert: Bool
    @Binding var showProgressView: Bool
    @EnvironmentObject var bidManager: BidManager
    @EnvironmentObject var settingsManager: SettingsManager
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
                }.pickerStyle(.inline).labelsHidden()
            } label: {
                Image(systemName: "chair.lounge")
            }.onChange(of: bidManager.bidpack.seat) { _ in // Deprecated iOS 17
                Task {
                    try? await settingsManager.save()
                }
            }
        }
        
        ToolbarItem {
            Menu {
                Toggle("Show Regular Lines", isOn: $bidManager.bidpack.showRegularLines)
                Toggle("Show Secondary Lines", isOn: $bidManager.bidpack.showSecondaryLines)
                Toggle("Show Reserve Lines", isOn: $bidManager.bidpack.showReserveLines)
                Toggle("Show only deadheads", isOn: $bidManager.filterDeadheads)
            } label: {
                Image(systemName: "line.3.horizontal.decrease")
            }
        }
        ToolbarItem {
            Menu {
                Picker(selection: $bidManager.bidpack.sortLinesBy) {
                    ForEach(Bidpack.SortOptions.allCases, id: \.self) { sortItem in
                        Button { 
                            
                        } label: {
                            Label(sortItem.rawValue, systemImage: sortItem.symbol)
                        }
                    }
                } label: {
                    Text("Sort")
                }.pickerStyle(.inline).labelsHidden()
            } label: {
                Image(systemName: "arrow.up.arrow.down")
            }
            // Need to hang fileImporter here because a view cannot have two file importers
            .fileImporter(
                isPresented: $showAscFileImporter,
                allowedContentTypes: [UTType.asc]) { result in
                    switch result {
                    case .success(let url):
                        Task {
                            do {
                                if url.startAccessingSecurityScopedResource() {
                                    showProgressView = true
                                    await bidManager.loadBidpackWithString(try String(contentsOf: url), seat: settingsManager.settings.seat)
                                    showProgressView = false
                                    bidManager.scrollSnap = .neutral
                                    bidManager.scrollNow = true
                                }
                                url.stopAccessingSecurityScopedResource()
                            }
                            catch {
                                fatalError(error.localizedDescription)
                            }
                        }
                    case .failure(let error):
                        print("failure")
                    }
                }
        }
        ToolbarItem {
            Button {
                showSheet = true
            } label: {
                Image(systemName: "calendar.badge.minus")
            }.popover(isPresented: $showSheet) {
                VStack {
                    Button("Clear Dates", role: .destructive) {
                        bidManager.avoidedDateComponents.removeAll()
                    }
                    #if os(iOS)
                    MultiDatePicker("Dates", selection: $bidManager.avoidedDateComponents, in: bidManager.bidpack.dateRange)
                    #endif
                }.padding()
            }
        }
        ToolbarItem {
            Menu {
                Button {
                    showAscFileImporter = true
                } label: {
                    Label("Open New Bidpack", systemImage: "doc")
                }
                
                Button(role: .destructive) {
                    showResetAlert = true
                } label: {
                    Label("Clear Bids & Avoids", systemImage: "clear")
                }
                
                Button {
                    showSavedBidExporter = true
                } label: {
                    Label("Save Current Bid", systemImage: "square.and.arrow.down")
                }
                
                Button {
                    showSavedBidImporter = true
                } label: {
                    Label("Load Saved Bid", systemImage: "arrow.down.doc")
                }
            } label: {
                Image(systemName: "folder")
            }
                .fileImporter(
                    isPresented: $showSavedBidImporter, allowedContentTypes: [.json]) { result in
                    switch result {
                    case .success(let url):
                            Task {
                                do {
                                    if url.startAccessingSecurityScopedResource() {
                                        try await bidManager.loadSnapshot(data: Data(contentsOf: url))
                                    }
                                    url.stopAccessingSecurityScopedResource()
                                }
                                catch {
                                    fatalError(error.localizedDescription)
                                }
                            }
                    case .failure(let error):
                        print("failure")
                    }
                }
                    .fileExporter(isPresented: $showSavedBidExporter, document: BidpackDocument(bidpack: bidManager.bidpack), contentType: .json, defaultFilename: bidManager.suggestedBidFileName) { result in
                    switch result {
                    case .success(let url):
                        print("success")
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
        }
        
        ToolbarItem {
            Spacer()
        }
    }
}
