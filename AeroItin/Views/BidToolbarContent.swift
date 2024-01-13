//
//  BidToolbarContent.swift
//  AeroItin
//
//  Created by Matt Zayatz on 11/1/23.
//

import SwiftUI

struct BidToolbarContent: ToolbarContent {
    @Binding var showFileImporter: Bool
    @Binding var showFileExporter: Bool
    @State var boop = false
    @Binding var showResetAlert: Bool
    @EnvironmentObject var bidManager: BidManager
    @State var showSheet = false
    
    var body: some ToolbarContent {
        ToolbarItem {
            Button {
                boop = true
            } label: {
                Image(systemName: "logo.xbox")
            }
            .fileImporter(isPresented: $boop, allowedContentTypes: [.json]) { result in
                switch result {
                case .success(let url):
//                                        guard let bidpackConents = try? String(contentsOf: url) else {
//                                            fatalError("crash!")
//                                        }
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
        }
        ToolbarItem {
            Button {
                showFileExporter = true
            } label: {
                Image(systemName: "eye")
            }
        }
        ToolbarItem {
            Button {
                Task {
                    try? await bidManager.saveSnapshot()
                }
            } label: {
                Image(systemName: "archivebox")
            }
        }
        ToolbarItem {
            Button {
                Task {
                    try? await bidManager.loadSnapshot()
                }
            } label: {
                Image(systemName: "archivebox.fill")
            }
        }
        ToolbarItem {
            Menu {
                Picker(selection:
                        $bidManager.bidpack.seat) {
                    Text(Bidpack.Seat.captain.rawValue).tag(Bidpack.Seat.captain)
                    Text(Bidpack.Seat.firstOfficer.rawValue).tag(Bidpack.Seat.firstOfficer)
                } label: {
                    Text("Seat")
                }.pickerStyle(.inline)
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
                }.pickerStyle(.inline)
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
