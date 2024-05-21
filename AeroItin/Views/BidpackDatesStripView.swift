//
//  BidpackDatesStripView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 9/4/23.
//

import SwiftUI

struct BidpackDatesStripView: View {
    let dates: [BidPeriodDate]
    let timeZone: TimeZone
    
    let strokeWidth = 2.0
    let dayWidth: CGFloat
    
    var body: some View {
        LazyHStack(spacing: 0) {
            ForEach(dates.indices, id: \.self) { i in
                ZStack {
                    BidpackDateView(date: dates[i], timeZone: timeZone)
                        .frame(width: dayWidth)
                    if(i > dates.count - 8) {
                        Color.yellow.opacity(0.2)
                    }
                }
            }
        }.frame(alignment: .leading)
    }
}

//struct BidpackDatesStrip_Previews: PreviewProvider {
//    static var bidManager = BidManager(seat: .firstOfficer)
//    static var previews: some View {
//        GeometryReader { geometry in
//            VStack(alignment: .leading) {
//                BidpackDatesStripView()
//                
//            }.fixedSize()
//        }.environmentObject(bidManager)
//    }
//}
