//
//  BidpackDatesStripView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 9/4/23.
//

import SwiftUI

struct BidpackDatesStripView: View {
    @EnvironmentObject var bidManager: BidManager
    
    let dayWidth: CGFloat
    let lineLabelWidth: CGFloat
    
    let strokeWidth = 2.0
    
    var body: some View {
            HStack(spacing: 0) {
                ForEach(bidManager.bidpack.dates, id: \.self) { date in
                    ZStack {
                        Rectangle()
                            .foregroundColor(date.isWeekend ? .secondary.opacity(0.25) : .clear)
                            .border(.secondary.opacity(0.6))
                        Text(DateFormatter.dayStringFor(date: date, in: bidManager.bidpack.base.timeZone))
                            .font(.callout)
                            .foregroundColor(.secondary.opacity(0.6))
                    }
                }.frame(width: dayWidth)
            }.frame(alignment: .leading)
    }
    
}

struct BidpackDatesStrip_Previews: PreviewProvider {
    static var bidManager = BidManager(seat: .firstOfficer)
    static var previews: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                BidpackDatesStripView(dayWidth: bidManager.dayWidth(geometry), lineLabelWidth: bidManager.lineLabelWidth)
                
            }.fixedSize()
        }.environmentObject(bidManager)
    }
}
