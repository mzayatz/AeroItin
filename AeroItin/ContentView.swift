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
//            List {
                List(bidManager.bidpack.lines, id: \.id) { line in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(line.number): CH: \(line.summary.creditHours.asHours) - \(line.flag.description)")
                            Text("BH: \(line.summary.blockHours.asHours) - LDG: \(line.summary.landings) - Days off \(line.summary.daysOff)")
                            Text("DPs: \(line.summary.dutyPeriods)")
                        }
                        Text("✅").onTapGesture {
                            bidManager.bidLine(line: line)
                        }
                        Text("⛔️").onTapGesture {
                            bidManager.avoidLine(line: line)
                        }
                        Text("↩️").onTapGesture {
                            bidManager.resetLine(line: line)
                        }
                        Text("⬆️").onTapGesture {
                            bidManager.moveLineUpOne(line: line)
                        }
                        Text("⬇️").onTapGesture {
                            bidManager.moveLineDownOne(line: line)
                        }
                    }
//                }
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
