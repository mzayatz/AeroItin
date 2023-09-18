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
    let secondsWidth: CGFloat
    
    var body: some View {
        ZStack {
            Rectangle()
            Text(trip.number).foregroundColor(.white)
        }
        .frame(width: secondsWidth * trip.timeAwayFromBase)
        .offset(offset)
        .onTapGesture {
            print(trip.firstEffectiveDate)
        }
    }
    
    var offset: CGSize {
        CGSize(width: secondsWidth * trip.firstEffectiveDate.timeIntervalSince(bidManager.bidpack.startDateLocal), height: 0)
    }
    
}

struct TripView_Previews: PreviewProvider {
    static var bidManager = BidManager(seat: .firstOfficer)
    static var previews: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                TripView(trip: bidManager.bidpack.lines[85].trips[0], secondsWidth: bidManager.secondWidth(geometry)).environmentObject(bidManager)
                TripView(trip: bidManager.bidpack.lines[85].trips[1], secondsWidth: bidManager.secondWidth(geometry)).environmentObject(bidManager)
                TripView(trip: bidManager.bidpack.lines[85].trips[2], secondsWidth: bidManager.secondWidth(geometry)).environmentObject(bidManager)
                TripView(trip: bidManager.bidpack.lines[85].trips[3], secondsWidth: bidManager.secondWidth(geometry)).environmentObject(bidManager)
                TripView(trip: bidManager.bidpack.lines[85].trips[4], secondsWidth: bidManager.secondWidth(geometry)).environmentObject(bidManager)
            }
        }.frame(height: 25.0)
    }
}
