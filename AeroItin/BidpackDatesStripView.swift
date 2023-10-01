//
//  BidpackDatesStripView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 9/4/23.
//

import SwiftUI

struct BidpackDatesStripView: View, Equatable {
    //    @EnvironmentObject var bidManager: BidManager
    
    let bidpackDates: [Date]
    let bidpackTimeZone: TimeZone
    let dayWidth: CGFloat
    let lineLabelWidth: CGFloat
    
    let strokeWidth = 2.0
    
    var body: some View {

        LazyHStack(spacing: 0) {
            ForEach(bidpackDates, id: \.self) { date in
                BidpackDateView(date: date, timeZone: bidpackTimeZone).frame(width: dayWidth)
                    .frame(width: dayWidth)
            }
        }.frame(alignment: .leading)
    }
    
}

struct BidpackDatesStrip_Previews: PreviewProvider {
    static var bidManager = BidManager(seat: .firstOfficer)
    static var previews: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                BidpackDatesStripView(bidpackDates: bidManager.bidpack.dates, bidpackTimeZone: bidManager.bidpack.base
                    .timeZone, dayWidth: bidManager.dayWidth(geometry), lineLabelWidth: bidManager.lineLabelWidth)
                
            }.fixedSize()
        }.environmentObject(bidManager)
    }
}
