//
//  TripView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 9/5/23.
//

import SwiftUI

struct TripView: View {
    let trip: Trip
    let dayWidth: CGFloat
    let startDateLocal: Date?
    @Environment(BidManager.self) private var bidManager: BidManager
    
    var secondWidth: CGFloat {
        dayWidth / (24 * 3600)
    }
    
    var startDateLocalOr1971: Date {
        startDateLocal ?? Date(timeIntervalSince1970: .day * 365)
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(tripColor.opacity(0.55))
            TripCaptionView(number: trip.number, description: trip.shortDescription, isRfo: trip.isRfo)
        }
        .onTapGesture(perform: tripTapHandler)
        .frame(width: secondWidth * trip.timeAwayFromBase)
        .offset(offset)
    }
    
    private var offset: CGSize {
        CGSize(width: secondWidth * trip.startDateTime.timeIntervalSince(startDateLocalOr1971), height: 0)
    }
    
    private var tripColor: Color {
        switch trip.deadheads {
        case .double: return .orange
        case .front: return .blue
        case .back: return .green
        case .none: return .yellow
        }
    }
    
    private func tripTapHandler() {
        @Bindable var bidManager = bidManager
        if(bidManager.showTripText) {
            withAnimation(.bouncy) {
                bidManager.selectedTripText = trip.text.joined(separator: "\n")
            }
        } else {
            bidManager.selectedTripText = trip.text.joined(separator: "\n")
            bidManager.showTripText = true
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
