//
//  BidpackDatesStripView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 9/4/23.
//

import SwiftUI

struct BidpackDatesStripView: View {
    @EnvironmentObject var bidManager: BidManager
    
    let height = 25.0
    let strokeWidth = 2.0
    let parentGeometry: GeometryProxy
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                Rectangle().stroke(style: StrokeStyle(lineWidth: strokeWidth))
                HStack(spacing: 0) {
                    ForEach(bidManager.bidpack.dates, id: \.self) { date in
                        ZStack {
                            Rectangle().stroke()
                            Text(DateFormatter.dayStringFor(date: date, in: bidManager.bidpack.base.timeZone))
                        }
                    }
                }
            }.frame(height: height)
        }
    }
    
}

struct BidpackDatesStrip_Previews: PreviewProvider {
    static var bidManager = BidManager(seat: .firstOfficer)
    static var previews: some View {
        GeometryReader { geometry in
            BidpackDatesStripView(parentGeometry: geometry).environmentObject(bidManager)
        }
    }
}
