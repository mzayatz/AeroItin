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
        NavigationStack {
            List {
                ForEach(bidManager.bidpack.lines) { line in
                    HStack {
                        Image(systemName: "plus.circle").foregroundColor(line.flag == .bid ? .gray : .green).onTapGesture {
                            line.flag == .bid ? bidManager.resetLine(line: line) :
                            bidManager.bidLine(line: line)
                        }
                        LineView(line: line)
                        Image(systemName: "minus.circle").foregroundColor(line.flag == .avoid ? .gray : .red).onTapGesture {
                            line.flag == .avoid ? bidManager.resetLine(line: line) :
                            bidManager.avoidLine(line: line)
                        }
                    }
                }.onMove { bidManager.moveLine(from: $0, toOffset: $1)}
            }
            .navigationTitle("AeroItin")
            .toolbar {
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
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(BidManager(seat: .firstOfficer))
    }
}
