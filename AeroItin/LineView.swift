//
//  LineView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 9/5/23.
//

import SwiftUI

struct LineView: View {
    let line: Line
    @EnvironmentObject var bidManager: BidManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            BidpackDatesStripView()
            HStack(spacing: 0) {
                Text(line.number).frame(width: bidManager.dayWidth * 2.2, alignment: .leading)
                ForEach(line.trips.indices, id: \.self) {
                    TripView(trip: line.trips[$0], height: 25.0)
                }
            }
        }
    }
}

struct LineView_Previews: PreviewProvider {
    static var bidManager = BidManager(seat: .firstOfficer)
    static var previews: some View {
        LineView(line: bidManager.bidpack.lines[47]).environmentObject(bidManager)
    }
}
