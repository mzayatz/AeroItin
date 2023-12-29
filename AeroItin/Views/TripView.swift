//
//  TripView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 9/5/23.
//

import SwiftUI

struct TripView: View {
    let trip: Trip
    @EnvironmentObject var bidManager: BidManager
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(tripColor).opacity(0.55)
            Text(trip.shortDescription).foregroundColor(Color.primary)
                .padding(1.5)
                .background(.background.opacity(0.5))
                .font(.footnote)

        }.onTapGesture {
            withAnimation {
                bidManager.selectedTripText = trip.text.joined(separator: "\n")
            }
        }
        .frame(width: bidManager.secondWidth * trip.timeAwayFromBase)
        .offset(offset)
    }
    
    var offset: CGSize {
        CGSize(width: bidManager.secondWidth * trip.firstEffectiveDate.timeIntervalSince(bidManager.bidpack.startDateLocal), height: 0)
    }
    
    var tripColor: Color {
        switch trip.deadheads {
        case .double:
            return .orange
        case .front:
            return .blue
        case .back:
            return .green
        case .none:
            return .yellow
        }
    }
    
}

//struct TripView_Previews: PreviewProvider {
//    static var bidManager = BidManager(seat: .firstOfficer)
//    static var previews: some View {
//        GeometryReader { geometry in
//            ZStack(alignment: .leading) {
//                TripView(trip: bidManager.bidpack.lines[85].trips[0])
//                TripView(trip: bidManager.bidpack.lines[85].trips[1])
//                TripView(trip: bidManager.bidpack.lines[85].trips[2])
//                TripView(trip: bidManager.bidpack.lines[85].trips[3])
//                TripView(trip: bidManager.bidpack.lines[85].trips[4])
//                TripView(trip: bidManager.bidpack.lines[85].trips[5])
//            }.environmentObject(bidManager)
//        }.frame(height: 25.0)
//            .environmentObject(bidManager)
//    }
//}
