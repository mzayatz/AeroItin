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
    let parentGeometry: GeometryProxy
    
    var body: some View {
        ZStack {
            Rectangle()
            .frame(
                width: widthFor(trip: trip, geometry: parentGeometry),
                height: height)
            .offset(offsetFor(date: trip.firstEffectiveDate, geometry: parentGeometry))
        }
    }
    
    func secondWithIn(_ geometry: GeometryProxy) -> CGFloat {
        bidManager.secondWidth(for: geometry.size)
    }
    
    func widthFor(trip: Trip, geometry: GeometryProxy) -> CGFloat {
        secondWithIn(geometry) * trip.timeAwayFromBase
    }
    
    func offsetFor(date: Date, geometry: GeometryProxy) -> CGSize {
        let x = CGSize(width: secondWithIn(geometry) * date.timeIntervalSince(bidManager.bidpack.startDateLocal), height: 0)
        return x
    }
}

struct TripView_Previews: PreviewProvider {
    static var bidManager = BidManager(seat: .firstOfficer)
    static var previews: some View {
        GeometryReader { geometry in
            TripView(trip: bidManager.bidpack.lines[1].trips[0], height: 25, parentGeometry: geometry).environmentObject(bidManager)
        }
    }
}
