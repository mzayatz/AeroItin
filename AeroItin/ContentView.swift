//
//  ContentView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 8/29/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var bidManager: BidManager
    
    var body: some View {
        
        GeometryReader { geometry in
            NavigationStack {
                ZStack(alignment: .bottom) {
                    List {
                        if(!bidManager.bidpack.bids.isEmpty) {
                            Section(header: Text("Bid")) {
                                ForEach(bidManager.bidpack.bids) { line in
                                    HStack {
                                        Image(systemName: "plus.circle").foregroundColor(.gray).onTapGesture {
                                            withAnimation {
                                                bidManager.bidpack.transferLine(line: line, action: .fromBidsToLines, byAppending: false)
                                            }
                                        }
                                        LineView(line: line)
                                        Image(systemName: "minus.circle").foregroundColor(.red).onTapGesture {
                                            withAnimation {
                                                bidManager.bidpack.transferLine(line: line, action: .fromBidsToAvoids)
                                            }
                                        }
                                    }
                                }.onMove { bidManager.bidpack.bids.move(fromOffsets: $0, toOffset: $1) }
                            }
                        }
                        Section(header: Text("Lines")) {
                            
                            ForEach(bidManager.bidpack.lines) { line in
                                HStack {
                                    Image(systemName: "plus.circle").foregroundColor(.green).onTapGesture {
                                        withAnimation {
                                            bidManager.bidpack.transferLine(line: line, action: .fromLinesToBids)
                                        }
                                    }
                                    LineView(line: line)
                                    Image(systemName: "minus.circle").foregroundColor(.red).onTapGesture {
                                        withAnimation {
                                            bidManager.bidpack.transferLine(line: line, action: .fromLinesToAvoids)
                                        }
                                    }
                                }
                            }.onMove { bidManager.bidpack.lines.move(fromOffsets: $0, toOffset: $1) }
                        }
                        if(!bidManager.bidpack.avoids.isEmpty) {
                            Section(header: Text("Avoids")) {
                                ForEach(bidManager.bidpack.avoids) { line in
                                    HStack {
                                        Image(systemName: "plus.circle").foregroundColor(.green).onTapGesture {
                                            withAnimation {
                                                bidManager.bidpack.transferLine(line: line, action: .fromAvoidsToBids)
                                            }
                                        }
                                        LineView(line: line)
                                        Image(systemName: "minus.circle").foregroundColor(.gray).onTapGesture {
                                            withAnimation {
                                                bidManager.bidpack.transferLine(line: line, action: .fromAvoidsToLines)
                                            }
                                        }
                                    }
                                }.onMove { bidManager.bidpack.avoids.move(fromOffsets: $0, toOffset: $1) }
                            }
                        }
                    }
                    .animation(.default, value: bidManager.bidpack.sortLinesBy)
                    .moveDisabled(!bidManager.bidpack.searchFilter.isEmpty)
                    .searchable(text: $bidManager.bidpack.searchFilter)
                    .navigationTitle("AeroItin")
                    .toolbar {
                        Menu {
                            HStack {
                                Picker(selection:
                                        $bidManager.bidpack.seat) {
                                    Text(Bidpack.Seat.captain.abbreviatedSeat).tag(Bidpack.Seat.captain)
                                    Text(Bidpack.Seat.firstOfficer.abbreviatedSeat).tag(Bidpack.Seat.firstOfficer)
                                } label: {
                                    Text("Seat")
                                }
                                Button("Clear all") {
                                    bidManager.resetBid()
                                }
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
            }.onAppear {
                bidManager.geometry = geometry
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(BidManager(seat: .firstOfficer))
    }
}
