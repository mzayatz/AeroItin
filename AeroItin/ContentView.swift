//
//  ContentView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 8/29/23.
//

import SwiftUI



struct ContentView: View {
    @EnvironmentObject var bidManager: BidManager
    @State var searchText = ""
    var body: some View {
        
        NavigationStack {
            ZStack(alignment: .bottom) {
                List {
                    LineListSectionView(section: .bid)
                    LineListSectionView(section: .neutral)
                    LineListSectionView(section: .avoid)
                }
                .animation(.default, value: bidManager.bidpack.sortLinesBy)
                .animation(.default, value: bidManager.searchFilter)
                .searchable(text: $bidManager.searchFilter).textInputAutocapitalization(.never).autocorrectionDisabled()
                .navigationTitle("AeroItin")
                .toolbar {
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
                if bidManager.selectedTripText != nil {
                    TripTextView(selectedTripText: $bidManager.selectedTripText)
                        .transition(AnyTransition.move(edge: .bottom))
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(BidManager(seat: .firstOfficer))
    }
}

