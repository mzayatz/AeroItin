//
//  LineView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 9/5/23.
//

import SwiftUI

struct LineView: View {
    let line: Line
    let bidpackDates: [Date]
    let bidpackStartDate: Date
    let bidpackTimeZone: TimeZone
    let dayWidth: CGFloat
    let secondWidth: CGFloat
    let lineLabelWidth: CGFloat
    @Binding var selectedTripText: String?
    
    
    var body: some View {
        HStack {
            Text(line.number).font(.headline).frame(width: lineLabelWidth, alignment: .leading)
            ScrollView(.horizontal) {
                ZStack(alignment: .leading) {
                    Rectangle().fill(backgroundColor())
                    BidpackDatesStripView(bidpackDates: bidpackDates, bidpackTimeZone: bidpackTimeZone, dayWidth: dayWidth, lineLabelWidth: lineLabelWidth)
                    ZStack(alignment: .leading) {
                        ForEach(line.trips.indices, id: \.self) {
                            TripView(bidpackStartDate: bidpackStartDate, trip: line.trips[$0], secondWidth: secondWidth, selectedTripText: $selectedTripText)
                        }
                    }
                }
            } 
        }.frame(height: 35)
    }
    
    func backgroundColor() -> Color {
        switch line.flag {
        case .avoid:
            return .red.opacity(0.25)
        case .bid:
            return .green.opacity(0.25)
        case .neutral:
            return .clear
        }
    }
}

struct LineView_Previews: PreviewProvider {
    static var bidManager = BidManager(seat: .firstOfficer)
    static var previews: some View {
        GeometryReader { geometry in
            List {
                ForEach(0..<10) { _ in
                    LineView(line: bidManager.bidpack.lines.randomElement()!, bidpackDates: bidManager.bidpack.dates, bidpackStartDate: bidManager.bidpack.startDateLocal, bidpackTimeZone: bidManager.bidpack
                        .base.timeZone, dayWidth: bidManager.dayWidth(geometry), secondWidth: bidManager.secondWidth(geometry), lineLabelWidth: bidManager.lineLabelWidth, selectedTripText: Binding.constant(nil))
                }
            }
        }
    }
}
