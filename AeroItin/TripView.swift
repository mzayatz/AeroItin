//
//  TripView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 9/5/23.
//

import SwiftUI



struct TripView: View {
//    @EnvironmentObject var bidManager: BidManager
    let bidpackStartDate: Date
    let trip: Trip
    let secondsWidth: CGFloat
    @State private var showSheet = false
    
    var body: some View {
//        NavigationLink {
//            TripTextView(text: trip.textRows.joined(separator: "\n"))
//        } label: {
             ZStack {
                //            Rectangle().foregroundColor(Color(.systemBackground)).opacity(0.5)
                Rectangle()
                    .foregroundStyle(tripColor).opacity(0.55)
//                if !trip.shortDescription.isEmpty {
                        Text(trip.shortDescription).foregroundColor(Color.primary)
                            .padding(1.5)
                            .background(.background.opacity(0.5))
                            .font(.footnote)
//                    .fixedSize()
//                }
//             }
             }.onTapGesture {
                 showSheet = true
             }
        .frame(width: secondsWidth * trip.timeAwayFromBase)
        .offset(offset)
        .sheet(isPresented: $showSheet) {
            TripTextView(text: trip.textRows.joined(separator: "\n"))
        }
    }
    
    var offset: CGSize {
        CGSize(width: secondsWidth * trip.firstEffectiveDate.timeIntervalSince(bidpackStartDate), height: 0)
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
                TripView(bidpackStartDate: bidManager.bidpack.startDateLocal, trip: bidManager.bidpack.lines[85].trips[0], secondsWidth: bidManager.secondWidth(geometry)).environmentObject(bidManager)
                TripView(bidpackStartDate: bidManager.bidpack.startDateLocal, trip: bidManager.bidpack.lines[85].trips[1], secondsWidth: bidManager.secondWidth(geometry)).environmentObject(bidManager)
                TripView(bidpackStartDate: bidManager.bidpack.startDateLocal, trip: bidManager.bidpack.lines[85].trips[2], secondsWidth: bidManager.secondWidth(geometry)).environmentObject(bidManager)
                TripView(bidpackStartDate: bidManager.bidpack.startDateLocal, trip: bidManager.bidpack.lines[85].trips[3], secondsWidth: bidManager.secondWidth(geometry)).environmentObject(bidManager)
                TripView(bidpackStartDate: bidManager.bidpack.startDateLocal, trip: bidManager.bidpack.lines[85].trips[4], secondsWidth: bidManager.secondWidth(geometry)).environmentObject(bidManager)            }
        }.frame(height: 25.0)
    }
}
