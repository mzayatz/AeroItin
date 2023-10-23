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
                                        LineButton(line: line, action: .fromBidsToLines)
                                        LineView(line: line)
                                        LineButton(line: line, action: .fromBidsToAvoids)
                                    }
                                }.onMove { bidManager.bidpack.bids.move(fromOffsets: $0, toOffset: $1) }
                            }
                        }
                        Section(header: Text("Lines")) {
                            
                            ForEach(bidManager.lines) { line in
                                HStack {
                                    LineButton(line: line, action: .fromLinesToBids)
                                    LineView(line: line)
                                    LineButton(line: line, action: .fromLinesToAvoids)
                                }
                                .moveDisabled(!bidManager.searchFilter.isEmpty)
                                
                            }.onMove { bidManager.bidpack.lines.move(fromOffsets: $0, toOffset: $1) }
                        }
                        if(!bidManager.bidpack.avoids.isEmpty) {
                            Section(header: Text("Avoids")) {
                                ForEach(bidManager.bidpack.avoids) { line in
                                    HStack {
                                        LineButton(line: line, action: .fromAvoidsToBids)
                                        LineView(line: line)
                                        LineButton(line: line, action: .fromAvoidsToLines)
                                    }
                                }.onMove { bidManager.bidpack.avoids.move(fromOffsets: $0, toOffset: $1) }
                            }
                        }
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(BidManager(seat: .firstOfficer))
    }
}
//
//struct BiddingListSection: View {
//    @EnvironmentObject var bidManager: BidManager
//    let listType: Line.Flag
//    
//    var lines: [Line] {
//        switch listType {
//        case .neutral:
//            return bidManager.lines
//        case .bid:
//            return bidManager.bidpack.bids
//        case .avoid:
//            return bidManager.bidpack.avoids
//        }
//    }
//    
//    var plusActionWith: (Line) -> Void {
//        switch listType {
//        case .neutral:
//            return bidManager.bidLine
//        case .bid:
//            return bidManager.unbidLine
//        case .avoid:
//            return bidManager.bidAlreadyAvoidedLine
//        }
//    }
//    
//    var minusActionWith: (Line) -> Void {
//        switch listType {
//        case .neutral:
//            return bidManager.avoidLine
//        case .bid:
//            return bidManager.avoidAlreadyBidLine
//        case .avoid:
//            return bidManager.unavoidLine
//        }
//    }
//    
//    var body: some View {
//        ForEach(lines) { line in
//            HStack {
//                Image(systemName: "plus.circle").foregroundColor(.gray).onTapGesture {
//                    withAnimation {
//                        plusActionWith(line)
//                    }
//                }
//                LineView(line: line)
//                Image(systemName: "minus.circle").foregroundColor(.red).onTapGesture {
//                    withAnimation {
//                        minusActionWith(line)
//                    }
//                }
//            }
//        }
//    }
//    
//}
