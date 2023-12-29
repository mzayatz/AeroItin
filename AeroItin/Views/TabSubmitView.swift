//
//  TabSubmitView.swift
//  FastBid
//
//  Created by Matt Zayatz on 4/24/23.
//

import SwiftUI

struct TabSubmitView: View {
    @State private var showEmptyBidAlert = false
    @EnvironmentObject var bidManager: BidManager
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section("Questions") {
                        Toggle(isOn: $bidManager.settings.protectMinDaysForRecurrentTraining) {
                            Text("Recurrent training: Drop to protect min days off?")
                            Text("If you have recurrent training, do you want to drop activities to protect minimum days off?")
                        }
                        
                        Toggle(isOn: $bidManager.settings.waiveIntlBufferForReccurentTraining) {
                            Text("Recurrent training: Waive int'l buffers?")
                            Text("Do you want to waive int'l duty free buffers to schedule recurrent training closer to a trip?")
                        }
                        
                        Toggle(isOn: $bidManager.settings.waiveIntlBufferToAvoidPhaseInConflict) {
                            Text("Phase-in conflict: Waive int'l buffers?")
                            Text("Do you want to waive your int'l duty free buffers to prevent a phase-in conflict?")
                        }
                        
                        Toggle(isOn: $bidManager.settings.waive1in10LegalityToAvoidPhaseInConflict) {
                            Text("Phase-in conflict: Waive 1-in-10?")
                            Text("Do you want to waive your 1-in-10 legality to prevent a phase-in conflict?")
                        }
                        
                        Toggle(isOn: $bidManager.settings.protectMinDaysDueToCarryover) {
                            Text("Previous month carryover: Drop to protect min days off?")
                            Text("If you have carryover from last month, do you want activities dropped to protect min days off?")
                        }
                    }
                    Section {
#if os(iOS)
                        LabeledContent {
                            TextField("", text: $bidManager.settings.employeeNumber, prompt: Text("Required"))
                        } label: {
                            Text("Employee #:")
                        }
#elseif os(macOS)
                        TextField("Employee #:", text: $bidManager.settings.employeeNumber, prompt: Text("Required")).fixedSize()
#endif


                        HStack { Text("Month / Base / Equipment / Seat: "); Text(bidManager.bidpackDescription).foregroundStyle(.secondary) }
                    } header: {
                        Text("Confirmation")
                    } footer: {
                        Text("Change seat on lines tab.")
                    }
                }
            }.navigationTitle("Submit")
        }.formStyle(.grouped)
    }
}

//#Preview {
//    return TabSubmitView().environmentObject(BidManager(seat: .firstOfficer))
//}
