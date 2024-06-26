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
    @Binding var alertType: TabViewLines.AlertType?
    @Binding var showProgressView: Bool
    @Environment(BidManager.self) private var bidManager: BidManager
    @EnvironmentObject var settingsManager: SettingsManager
    @State var showSheet = false
    @Binding var showPilotAwardSheet: Bool
    @Binding var showVerifyBidSheet: Bool
    @Binding var showAlert: Bool
    
    var body: some ToolbarContent {
        @Bindable var bidManager = bidManager
        ToolbarItem {
            Menu {
                Button {
                    showVerifyBidSheet = true
                } label: {
                    Label("Confirm bid", systemImage: "checkmark.shield")
                }
                
                Button {
                    showPilotAwardSheet = true
                } label: {
                    Label("Get awards", systemImage: "medal")
                }
            } label: {
                Label("VIPS Options", systemImage: "checkmark.icloud")
            }
        }
        
        ToolbarItem {
            Menu {
                Toggle("Show Regular Lines", isOn: $bidManager.showRegularLines)
                Toggle("Show Secondary Lines", isOn: $bidManager.showSecondaryLines)
                Toggle("Show Reserve Lines", isOn: $bidManager.showReserveLines)
                Toggle("Show only deadheads", isOn: $bidManager.filterDeadheads)
                
                Picker(selection: $bidManager.bidpack.seat) {
                    Text(Bidpack.Seat.captain.rawValue).tag(Bidpack.Seat.captain)
                    Text(Bidpack.Seat.firstOfficer.rawValue).tag(Bidpack.Seat.firstOfficer)
                } label: {
                    
                }
                .pickerStyle(.segmented)
                .onChange(of: bidManager.bidpack.seat) { 
                    Task {
                        try? await settingsManager.save()
                    }
                }
            } label: {
                Image(systemName: "line.3.horizontal.decrease")
            }
        }
        ToolbarItem {
            Menu {
                Picker(selection: $bidManager.sortLinesBy) {
                    ForEach(BidManager.SortOptions.allCases, id: \.self) { sortItem in
                        Label(sortItem.rawValue, systemImage: sortItem.symbol)
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
                                        //FIXME: The sort below ensures the listView updates...
                                        //FIXME: Without it, stale data can happen
                                        bidManager.sortLinesBy = .number
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
                            print("failure + \(error.localizedDescription)")
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
                        MultiDatePicker("Dates", selection: $bidManager.avoidedDateComponents, in: bidManager.dateRange)
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
                        alertType = .resetAlert
                        showAlert = true
                    } label: {
                        Label("Clear Bids & Avoids", systemImage: "clear")
                    }
                    
                    Button {
                        showSavedBidExporter = true
                    } label: {
                        Label("Save Bid", systemImage: "square.and.arrow.down")
                    }
                    
                    Button {
                        showSavedBidImporter = true
                    } label: {
                        Label("Load Bid", systemImage: "square.and.arrow.up")
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
                            print("failure \(error.localizedDescription)")
                        }
                    }
                    .fileExporter(isPresented: $showSavedBidExporter, document: BidpackDocument(bidpack: bidManager.bidpack), contentType: .json, defaultFilename: bidManager.suggestedBidFileName) { result in
                        switch result {
                        case .success(_):
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
