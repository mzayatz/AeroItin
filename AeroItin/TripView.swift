//
//  TripView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 9/5/23.
//

import SwiftUI



struct TripView: View {
    let bidpackStartDate: Date
    let trip: Trip
    let secondWidth: CGFloat
    @State private var showSheet = false
    @Binding var selectedTripText: String?
    
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
                selectedTripText = trip.textRows.joined(separator: "\n")
            }
        }
        .frame(width: secondWidth * trip.timeAwayFromBase)
        .offset(offset)
    }
    
    var offset: CGSize {
        CGSize(width: secondWidth * trip.firstEffectiveDate.timeIntervalSince(bidpackStartDate), height: 0)
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

struct TripView_Previews: PreviewProvider {
    static var bidManager = BidManager(seat: .firstOfficer)
    static var previews: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                TripView(bidpackStartDate: bidManager.bidpack.startDateLocal, trip: bidManager.bidpack.lines[85].trips[0], secondWidth: bidManager.secondWidth(geometry), selectedTripText: Binding.constant(nil)).environmentObject(bidManager)
                TripView(bidpackStartDate: bidManager.bidpack.startDateLocal, trip: bidManager.bidpack.lines[85].trips[1], secondWidth: bidManager.secondWidth(geometry), selectedTripText: Binding.constant(nil)).environmentObject(bidManager)
                TripView(bidpackStartDate: bidManager.bidpack.startDateLocal, trip: bidManager.bidpack.lines[85].trips[2], secondWidth: bidManager.secondWidth(geometry), selectedTripText: Binding.constant(nil)).environmentObject(bidManager)
                TripView(bidpackStartDate: bidManager.bidpack.startDateLocal, trip: bidManager.bidpack.lines[85].trips[3], secondWidth: bidManager.secondWidth(geometry), selectedTripText: Binding.constant(nil)).environmentObject(bidManager)
                TripView(bidpackStartDate: bidManager.bidpack.startDateLocal, trip: bidManager.bidpack.lines[85].trips[4], secondWidth: bidManager.secondWidth(geometry), selectedTripText: Binding.constant(nil)).environmentObject(bidManager)
            }
        }.frame(height: 25.0)
    }
}
