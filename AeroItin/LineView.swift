//
//  LineView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 9/5/23.
//

import SwiftUI

struct LineView: View, Equatable {
    let line: Line
    let bidpackDates: [Date]
    let bidpackStartDate: Date
    let bidpackTimeZone: TimeZone
    let dayWidth: CGFloat
    let secondWidth: CGFloat
    let lineLabelWidth: CGFloat
    
    //    @EnvironmentObject var bidManager: BidManager
    //    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        HStack {
            Text(line.number).font(.headline).frame(width: lineLabelWidth, alignment: .leading)
            ScrollView(.horizontal) {
                ZStack(alignment: .leading) {
//                    Color.clear.frame(width: dayWidth * CGFloat(bidpackDates.count))
                    BidpackDatesStripView(bidpackDates: bidpackDates, bidpackTimeZone: bidpackTimeZone, dayWidth: dayWidth, lineLabelWidth: lineLabelWidth)
                    ZStack(alignment: .leading) {
                        ForEach(line.trips.indices, id: \.self) {
                            TripView(bidpackStartDate: bidpackStartDate, trip: line.trips[$0], secondsWidth: secondWidth)
                        }
                    }
                    //                        BidpackDatesStripView(dayWidth: bidManager.dayWidth(geometry), lineLabelWidth: bidManager.lineLabelWidth)
                }
            }
        }.frame(height: 35)
    }
}

struct LineView_Previews: PreviewProvider {
    static var bidManager = BidManager(seat: .firstOfficer)
    static var previews: some View {
        NavigationStack {
            GeometryReader { geometry in
                List {
                    ForEach(0..<10) { _ in
                        LineView(line: bidManager.bidpack.lines.randomElement()!, bidpackDates: bidManager.bidpack.dates, bidpackStartDate: bidManager.bidpack.startDateLocal, bidpackTimeZone: bidManager.bidpack
                            .base.timeZone, dayWidth: bidManager.dayWidth(geometry), secondWidth: bidManager.secondWidth(geometry), lineLabelWidth: bidManager.lineLabelWidth)
                    }
                }
            }
        }
    }
}
