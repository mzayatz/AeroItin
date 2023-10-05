//
//  LineView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 9/5/23.
//

import SwiftUI

struct LineView: View {
    let line: Line
    @EnvironmentObject var bidManager: BidManager
    
    var body: some View {
        HStack {
            Text(line.number).font(.headline).frame(width: bidManager.lineLabelWidth, alignment: .leading)
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
                    LineView(line: bidManager.bidpack.lines.randomElement()!)
                }
            }
        }.environmentObject(bidManager)
    }
}
