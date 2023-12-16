//
//  SubmitBidView.swift
//  FastBid
//
//  Created by Matt Zayatz on 4/24/23.
//

import SwiftUI

struct SubmitBidView: View {
    @State private var protectMinDaysForRecurrentTraining = false
    @State private var waiveIntlBufferForReccurentTraining = false
    @State private var waiveIntlBufferToAvoidPhaseInConflict = false
    @State private var waive1in10LegalityToAvoidPhaseInConflict = false
    @State private var protectMinDaysDueToCarryover = false
    
    @State private var test = "3723834"
    
    @State private var showEmptyBidAlert = false
    @EnvironmentObject var bidManager: BidManager
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section("Questions") {
                        Toggle(isOn: $protectMinDaysForRecurrentTraining) {
                            Text("Recurrent training: Drop to protect min days off?")
                            Text("If you have recurrent training, do you want to drop activities to protect minimum days off?")
                        }
                        
                        Toggle(isOn: $waiveIntlBufferForReccurentTraining) {
                            Text("Recurrent training: Waive int'l buffers?")
                            Text("Do you want to waive int'l duty free buffers to schedule recurrent training closer to a trip?")
                        }
                        
                        Toggle(isOn: $waiveIntlBufferToAvoidPhaseInConflict) {
                            Text("Phase-in conflict: Waive int'l buffers?")
                            Text("Do you want to waive your int'l duty free buffers to prevent a phase-in conflict?")
                        }
                        
                        Toggle(isOn: $waive1in10LegalityToAvoidPhaseInConflict) {
                            Text("Phase-in conflict: Waive 1-in-10?")
                            Text("Do you want to waive your 1-in-10 legality to prevent a phase-in conflict?")
                        }
                        
                        Toggle(isOn: $protectMinDaysDueToCarryover) {
                            Text("Previous month carryover: Drop to protect min days off?")
                            Text("If you have carryover from last month, do you want activities dropped to protect min days off?")
                        }
                    }
                    Section {
                        LabeledContent("Employee #:") {
                            TextField("", text: $test)
                        }
                        HStack { Text("Month / Base / Equipment / Seat: "); Text(bidManager.bidpackDescription).foregroundStyle(.secondary) }
                    } header: {
                        Text("Confirmation")
                    } footer: {
                        Text("Change seat on lines tab.")
                    }
                }
            }.navigationTitle("Submit")
        }
    }
}

//#Preview {
//   return SubmitBidView()
//}
