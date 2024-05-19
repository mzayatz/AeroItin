//
//  NewTripView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 5/18/24.
//

import SwiftUI

struct NewTripView: View {
    let trip: Trip
    let secondWidth: CGFloat
    
    @Binding var selectedTripText: String?
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(tripColor.opacity(0.55))
            TripCaptionView(number: trip.number, description: trip.shortDescription, isRfo: trip.isRfo)
        }
        .onTapGesture(perform: tripTapHandler)
        .frame(width: secondWidth * trip.timeAwayFromBase)
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
        withAnimation {
            selectedTripText = trip.text.joined(separator: "\n")
        }
    }
}

#Preview {
    struct PreviewView: View {
        func x(_ line: Line) {
            
        }
        @State var selectedTripText: String? = ""
        @StateObject var bidManager = BidManager()
        var body: some View {
            NewTripView(trip: bidManager.bidpack.lines.randomElement()?.trips.randomElement() ?? Trip(), secondWidth: bidManager.secondWidth,  selectedTripText: $selectedTripText).task {
                try! await bidManager.loadBidpackWithString(String(contentsOf: BidManager.testingUrl))
            }
        }
    }
    return PreviewView()
}
