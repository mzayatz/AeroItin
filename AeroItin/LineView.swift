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
    //@Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .center) {
                Text(line.number).frame(width: bidManager.lineLabelWidth, alignment: .leading)
                VStack(alignment: .leading, spacing: 0) {
                    BidpackDatesStripView(height: bidManager.lineHeight, dayWidth: bidManager.dayWidth(geometry), lineLabelWidth: bidManager.lineLabelWidth)
                    HStack(spacing: 0) {
                        ZStack {
                            ForEach(line.trips.indices, id: \.self) {
                                TripView(trip: line.trips[$0], height: bidManager.lineHeight, secondsWidth: bidManager.secondWidth(geometry))
                            }
                        }
                    }
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
