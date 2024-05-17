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
            VStack(spacing: 2) {
                Text(trip.number).background(.background.opacity(0.5))
                Text(trip.shortDescription).foregroundColor(Color.primary).background(.background.opacity(0.5))
            }
            .padding(1.5)
            .font(trip.isRfo ? .caption2.italic() : .caption2)
            .underline(trip.isRfo)

        }.onTapGesture {
            withAnimation {
                bidManager.selectedTripText = trip.text.joined(separator: "\n")
            }
        }
        .frame(width: bidManager.secondWidth * trip.timeAwayFromBase)
        .offset(offset)
    }
    
    var offset: CGSize {
        CGSize(width: bidManager.secondWidth * trip.startDateTime.timeIntervalSince(bidManager.bidpack.startDateLocal), height: 0)
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
