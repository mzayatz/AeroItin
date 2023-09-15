//
//  TripView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 9/5/23.
//

import SwiftUI



struct TripView: View {
    @EnvironmentObject var bidManager: BidManager
    let trip: Trip
    let height: CGFloat
    let secondsWidth: CGFloat
    
    var body: some View {
        ZStack {
            Rectangle()
            .frame(
                width: secondsWidth * trip.timeAwayFromBase,
                height: height)
            .offset(offset)
        }
    }
    
    var offset: CGSize {
        CGSize(width: secondsWidth * trip.firstEffectiveDate.timeIntervalSince(bidManager.bidpack.startDateLocal), height: 0)
    }
    
}

//struct TripView_Previews: PreviewProvider {
//    static var bidManager = BidManager(seat: .firstOfficer)
//    static var previews: some View {
//        TripView(trip: bidManager.bidpack.lines[1].trips[0], height: 25 ).environmentObject(bidManager)
//    }
//}
