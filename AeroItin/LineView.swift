//
//  LineView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 9/5/23.
//

import SwiftUI

struct LineView: View {
    let line: Line
    let parentGeometry: GeometryProxy
    
    var body: some View {
        HStack(spacing: 0) {
            Text(line.number).fixedSize().padding(.trailing)
            ForEach(line.trips.indices, id: \.self) {
                TripView(trip: line.trips[$0], height: 25.0, parentGeometry: parentGeometry)
            }
        }
    }
}

struct LineView_Previews: PreviewProvider {
    static var bidManager = BidManager(seat: .firstOfficer)
    static var previews: some View {
        GeometryReader { geometry in
            LineView(line: bidManager.bidpack.lines[47], parentGeometry: geometry).environmentObject(bidManager)
        }
    }
}
