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
    
    @EnvironmentObject var bidManager: BidManager
    
    var body: some View {
        HStack {
            LineButton(line: line, action: section.plusTransferAction)
            VStack(alignment: .trailing)
            {
                Text(line.number).font(.footnote).frame(width: bidManager.lineLabelWidth, alignment: .trailing)
                HStack {
                    Text("\(attributeSymbol)  \(attributeText)").font(.caption).frame(alignment: .trailing)
                }
            }.frame(width: bidManager.lineLabelWidth)
            ScrollView(.horizontal) {
                ZStack(alignment: .leading) {
                    Rectangle().fill(backgroundColor())
                    BidpackDatesStripView()
                    ZStack(alignment: .leading) {
                        ForEach(line.trips.indices, id: \.self) {
                            TripView(trip: line.trips[$0])
                        }
                    }
                }
            } 
            LineButton(line: line, action: section.minusTransferAction)
        }.frame(height: bidManager.lineHeight)
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
    
    var attributeSymbol: Image {
        switch bidManager.bidpack.sortLinesBy {
        case .blockHours:
            return Image(systemName: "clock")
        case .creditHours:
            return Image(systemName: "creditcard")
        case .daysOff:
            return Image(systemName: "sunglasses.fill")
        case .dutyPeriods:
            return Image(systemName: "mappin.and.ellipse")
        case .landings:
            return Image(systemName: "airplane.arrival")
        case .number:
            return Image(systemName: "creditcard")
        }
    }
    
    var attributeText: String {
        switch bidManager.bidpack.sortLinesBy {
        case .blockHours:
            return line.summary.blockHours.asHours.formatted(.number.precision(.fractionLength(1)))
        case .creditHours:
            return line.summary.creditHours.asHours.formatted(.number.precision(.fractionLength(1)))
        case .daysOff:
            return String(line.summary.daysOff)
        case .dutyPeriods:
            return String(line.summary.dutyPeriods)
        case .landings:
            return String(line.summary.landings)
        case .number:
            return line.summary.creditHours.asHours.formatted(.number.precision(.fractionLength(1)))
        }
    }
}

//struct LineView_Previews: PreviewProvider {
//    static var bidManager = BidManager(seat: .firstOfficer)
//    static var previews: some View {
//            List {
//                ForEach(0..<10) { _ in
//                    LineView(line: bidManager.bidpack.lines.randomElement()!)
//                }
//            }.environmentObject(bidManager)
//    }
//}
