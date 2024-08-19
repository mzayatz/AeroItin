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
    
    @State private var textOne: Attribute
    @State private var textTwo: Attribute
    
    init(line: Line, section: Line.Flag, dates: [BidPeriodDate], timeZone: TimeZone) {
        self.line = line
        self.section = section
        self.dates = dates
        self.timeZone = timeZone
        
        self.textOne = Attribute.number
        self.textTwo = line.pilot != nil ? .pilot : .creditHours
    }
    
    var body: some View {
        HStack {
            VStack {
                Text(textOne.text(line: line)).font(.caption.monospaced())
                HStack {
                    Text(textTwo.text(line: line)).font(.caption.monospaced()).bold()
                }
            }.onTapGesture {
                textTwo = textTwo.next()
            }
            GeometryReader { geometry in
                let dayWidth = dayWidthFrom(geometry)
                ZStack(alignment: .leading) {
                    Rectangle().fill(line.userAward ? .green.opacity(0.50) : .clear)
                    BidpackDatesStripView(dates: dates, dayWidth: dayWidth)
                    ZStack(alignment: .leading) {
                        ForEach(line.trips) { trip in
                            TripView(trip: trip, dayWidth: dayWidth, startDateLocal: dates.first?.calendarDate)
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
    
    enum Attribute: CaseIterable {
        case creditHours
        case blockHours
        case daysOff
        case dutyPeriods
        case landings
        case number
        case pilot
        
        func text(line: Line) -> String {
            switch self {
            case .blockHours:
                return "BLK: " + line.summary.blockHours.asHours.formatted(.number.precision(.fractionLength(1)))
            case .creditHours:
                return " CR: " + line.summary.creditHours.asHours.formatted(.number.precision(.fractionLength(1)))
            case .daysOff:
                return "OFF: " + String(line.summary.daysOff)
            case .dutyPeriods:
                return "DTY: " + String(line.summary.dutyPeriods)
            case .landings:
                return "LDG: " + String(line.summary.landings)
            case .number:
                return line.number
            case .pilot:
                return line.pilot?.name.centerPadding(toLength: 10, withPad: " ") ?? "no pilot"
            }
        }
    }
    
    func dayWidthFrom(_ geometry: GeometryProxy) -> CGFloat {
        geometry.size.width / CGFloat(dates.count)
    }
}

