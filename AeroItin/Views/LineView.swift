//
//  LineView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 9/5/23.
//

import SwiftUI

struct LineView: View {
    let line: Line
    let section: Line.Flag
    
    let dates: [BidPeriodDate]
    let timeZone: TimeZone
    @Binding var selectedTripText: String?
    
    var body: some View {
        HStack {
            Text(line.number).font(.caption.monospaced())
            GeometryReader { geometry in
                let dayWidth = dayWidthFrom(geometry)
                ZStack(alignment: .leading) {
                    Rectangle().fill(backgroundColor())
                    BidpackDatesStripView(dates: dates, timeZone: timeZone, dayWidth: dayWidth)
                    ZStack(alignment: .leading) {
                        ForEach(line.trips) { trip in
                            TripView(trip: trip, dayWidth: dayWidth, startDateLocal: dates.first?.calendarDate, selectedTripText: $selectedTripText)
                        }
                    }
                }
            }
            //
        }
    }
    
    func backgroundColor() -> Color {
        switch section {
        case .avoid:
            return .red.opacity(0.25)
        case .bid:
            return .green.opacity(0.25)
        case .neutral:
            return .clear
        }
    }
    
//    var attributeSymbol: Image {
//        switch bidManager.bidpack.sortLinesBy {
//        case .blockHours:
//            return Image(systemName: "clock")
//        case .creditHours:
//            return Image(systemName: "creditcard")
//        case .daysOff:
//            return Image(systemName: "sunglasses.fill")
//        case .dutyPeriods:
//            return Image(systemName: "mappin.and.ellipse")
//        case .landings:
//            return Image(systemName: "airplane.arrival")
//        case .number:
//            return Image(systemName: "creditcard")
//        }
//    }
    
//    var attributeText: String {
//        switch bidManager.bidpack.sortLinesBy {
//        case .blockHours:
//            return line.summary.blockHours.asHours.formatted(.number.precision(.fractionLength(1)))
//        case .creditHours:
//            return line.summary.creditHours.asHours.formatted(.number.precision(.fractionLength(1)))
//        case .daysOff:
//            return String(line.summary.daysOff)
//        case .dutyPeriods:
//            return String(line.summary.dutyPeriods)
//        case .landings:
//            return String(line.summary.landings)
//        case .number:
//            return line.summary.creditHours.asHours.formatted(.number.precision(.fractionLength(1)))
//        }
//    }
    
    func dayWidthFrom(_ geometry: GeometryProxy) -> CGFloat {
        geometry.size.width / CGFloat(dates.count)
    }
}
