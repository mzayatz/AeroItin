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
                Text(line.number).font(.headline).frame(width: bidManager.lineLabelWidth, alignment: .leading)
                ScrollView(.horizontal) {
                    ZStack(alignment: .leading) {
                        BidpackDatesStripView(dayWidth: bidManager.dayWidth(geometry), lineLabelWidth: bidManager.lineLabelWidth)
                        ZStack(alignment: .leading) {
                            ForEach(line.trips.indices, id: \.self) {
                                TripView(trip: line.trips[$0], secondsWidth: bidManager.secondWidth(geometry))
                            }
                        }
//                        BidpackDatesStripView(dayWidth: bidManager.dayWidth(geometry), lineLabelWidth: bidManager.lineLabelWidth)
                    }
                }
            }
        }.frame(height: 35)
    }
}

struct LineView_Previews: PreviewProvider {
    static var bidManager = BidManager(seat: .firstOfficer)
    static var previews: some View {
        List {
            ForEach(0..<10) { _ in
                LineView(line: bidManager.bidpack.lines.randomElement()!)
            }
        }.environmentObject(bidManager)
    }
}
