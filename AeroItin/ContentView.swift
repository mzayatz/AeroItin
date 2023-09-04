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
        VStack {
            HStack {
                Button("sort neutrals") {
                    bidManager.sortNeturalLines()
                }
                Button("Reset") {
                    bidManager.resetBid()
                }
                
                Button("Reset but keep avoids") {
                    bidManager.resetBidButKeepAvoids()
                }
                Picker(selection: $bidManager.sortLinesBy) {
                    ForEach(Bidpack.SortOptions.allCases, id: \.self) { Text($0.rawValue) }
                } label: {
                    Text("Sort")
                }
            }
            List(bidManager.bidpack.lines, id: \.id) { line in
               TestLineView(line: line)
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(BidManager(seat: .firstOfficer))
    }
}
