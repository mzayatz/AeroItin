//
//  ContentView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 8/29/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var bidManager: BidManager
    @State var searchText = ""
    @State var showResetAlert = false
    @State var showFileImporter = false
    @State var scrolledId: Line.ID?
    var body: some View {
        
        NavigationStack {
            ZStack(alignment: .bottom) {
                List {
                    LineListSectionView(section: .bid)
                    LineListSectionView(section: .neutral)
                    LineListSectionView(section: .avoid)
                }
                .listStyle(.plain)
                .searchable(text:$bidManager.searchFilter)
                .autocorrectionDisabled()
                #if os(iOS)
                .textInputAutocapitalization(.never)
                #endif
                .navigationTitle(bidManager.bidpackDescription)
                .fileImporter(
                    isPresented: $showFileImporter,
                    allowedContentTypes: [UTType.asc]) { result in
                        switch result {
                        case .success(let url):
                            if url.startAccessingSecurityScopedResource() {
                                bidManager.loadBidpackFromUrl(url)
                            } else {
                                
                            }
                            url.stopAccessingSecurityScopedResource()
                        case .failure(let error):
                            print("failure")
                        }
                    }
                    .toolbar {
                        ToolbarItem {
                            Button {
                                showFileImporter = true
                            } label: {
                                Image(systemName: "folder")
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
                                Menu("Seat:  \(bidManager.bidpack.seat.rawValue)") {
                                    Picker(selection:
                                            $bidManager.bidpack.seat) {
                                        Text(Bidpack.Seat.captain.rawValue).tag(Bidpack.Seat.captain)
                                        Text(Bidpack.Seat.firstOfficer.rawValue).tag(Bidpack.Seat.firstOfficer)
                                    } label: {
                                        Text("Seat")
                                    }
                                }
                                Menu("Sort:  \(bidManager.bidpack.sortLinesBy.rawValue)") {
                                    Picker(selection: $bidManager.bidpack.sortLinesBy) {
                                        ForEach(Bidpack.SortOptions.allCases, id: \.self) { Text($0.rawValue) }
                                    } label: {
                                        Text("Sort")
                                    }
                                }
                            } label: {
                                Image(systemName: "gear")
                            }
                        }
                    }
                if bidManager.selectedTripText != nil {
                    TripTextView(selectedTripText: $bidManager.selectedTripText)
                        .transition(AnyTransition.move(edge: .bottom))
                }
            }
        }
    }
}

#Preview {
    return ContentView().environmentObject(BidManager(seat: .firstOfficer))
}
