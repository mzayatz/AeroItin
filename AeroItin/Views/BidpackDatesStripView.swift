//
//  BidpackDatesStripView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 9/4/23.
//

import SwiftUI

struct BidpackDatesStripView: View {
    @EnvironmentObject var bidManager: BidManager
    let strokeWidth = 2.0
    let dayWidth: CGFloat
    
    var body: some View {
        LazyHStack(spacing: 0) {
            ForEach(bidManager.bidpack.dates.indices, id: \.self) { i in
                ZStack {
                    BidpackDateView(date: bidManager.bidpack.dates[i], timeZone: bidManager.bidpack.base.timeZone)
                        .frame(width: dayWidth)
                    if(i > bidManager.bidpack.dates.count - 8) {
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
