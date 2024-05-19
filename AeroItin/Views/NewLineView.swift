//
//  NewLineView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 5/18/24.
//

import SwiftUI

struct NewLineView: View {
    @Binding var selectedTripText: String?
    
    let line: Line
    let section: Line.Flag
    let labelWidth: CGFloat
    let height: CGFloat
    let secondWidth: CGFloat
    let bidpackStartDateLocal: Date
    let sort: Bidpack.SortOptions
    
    let onBid: (Line) -> Void
    let onAvoid: (Line) -> Void
    
    var body: some View {
        HStack {
            Button {
                onBid(line)
            } label: {
                plusButtonImage
            }.buttonStyle(.plain)
            
            VStack(alignment: .trailing)
            {
                Text(line.number).font(.footnote).frame(width: labelWidth, alignment: .trailing)
                HStack {
                    Text("\(attributeSymbol)  \(attributeText)").font(.caption).frame(alignment: .trailing)
                }
            }.frame(width: labelWidth)
            ScrollView(.horizontal) {
                ZStack(alignment: .leading) {
                    Rectangle().fill(backgroundColor())
                    BidpackDatesStripView()
                    ZStack(alignment: .leading) {
                        ForEach(line.trips.indices, id: \.self) {
                            NewTripView(trip: line.trips[$0], secondWidth: secondWidth, selectedTripText: $selectedTripText).offset(calculateTripOffset(trip: line.trips[$0], secondWidth: secondWidth, bidpackStartDateLocal: bidpackStartDateLocal))
                        }
                    }
                }
            }
            Button {
                onAvoid(line)
            } label: {
                minusButtonImage
            }.buttonStyle(.plain)
        }.frame(height: height)
    }
    
    func calculateTripOffset(trip: Trip, secondWidth: CGFloat, bidpackStartDateLocal: Date) -> CGSize {
        CGSize(width: secondWidth * trip.startDateTime.timeIntervalSince(bidpackStartDateLocal), height: 0)
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
    
    var attributeSymbol: Image {
        switch sort {
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
        switch sort {
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
    
    var plusButtonImage: some View {
        switch section {
        case .avoid:
            return Image(systemName: "plus.circle").foregroundStyle(.green)
        case .bid:
            return Image(systemName: "plus.circle").foregroundStyle(.gray)
        case .neutral:
            return Image(systemName: "plus.circle").foregroundStyle(.green)
        }
    }
    
    var minusButtonImage: some View {
        switch section {
        case .avoid:
            return Image(systemName: "minus.circle").foregroundStyle(.gray)
        case .bid:
            return Image(systemName: "minus.circle").foregroundStyle(.red)
        case .neutral:
            return Image(systemName: "minus.circle").foregroundStyle(.red)
        }
    }
}

//#Preview {
//    struct PreviewView: View {
//        func x(_ line: Line) {
//            
//        }
//        @StateObject var bidManager = BidManager()
//        var body: some View {
//            NewLineView(line: bidManager.bidpack.lines.randomElement() ?? Line(number: "8001"), section: .neutral, labelWidth: bidManager.lineLabelWidth, sort: .number, onBid: x, onAvoid: x).task {
//                try! await bidManager.loadBidpackWithString(String(contentsOf: BidManager.testingUrl))
//            }
//        }
//    }
//    return PreviewView()
//}
