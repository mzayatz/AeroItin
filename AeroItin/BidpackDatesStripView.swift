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
    
    var body: some View {
            HStack(spacing: 0) {
                Rectangle().frame(width: bidManager.dayWidth * 2.2).foregroundColor(.gray)
                ForEach(bidManager.bidpack.dates, id: \.self) { date in
                    ZStack {
                        Rectangle().stroke()
                        Text(DateFormatter.dayStringFor(date: date, in: bidManager.bidpack.base.timeZone))
                    }
                }.frame(width: bidManager.dayWidth)
            }.frame(height: height, alignment: .leading)
    }
    
}

struct BidpackDatesStrip_Previews: PreviewProvider {
    static var bidManager = BidManager(seat: .firstOfficer)
    static var previews: some View {
        VStack(alignment: .leading) {
            BidpackDatesStripView().environmentObject(bidManager)
        }
    }
}
