//
//  TabSubmitView.swift
//  FastBid
//
//  Created by Matt Zayatz on 4/24/23.
//

import SwiftUI

struct TabSubmitView: View {
    @State private var showBlankEmployeeNumberAlert = false
    @State private var showNumberOfLinesBidAlert = false
    @State private var showExpiredBidPackAlert = false
    @State private var overrideExpiredBid = false
    
    @State private var showBidSubmitPage = false
    @Environment(BidManager.self) private var bidManager: BidManager
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var webViewModel: WebViewModel
    
    @State private var bid: Bid?
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section("Questions") {
                        Toggle(isOn: $settingsManager.settings.protectMinDaysForRecurrentTraining) {
                            Text("Recurrent training: Drop to protect min days off?")
                            Text("If you have recurrent training, do you want to drop activities to protect minimum days off?")
                        }
                        
                        Toggle(isOn: $settingsManager.settings.waiveIntlBufferForReccurentTraining) {
                            Text("Recurrent training: Waive int'l buffers?")
                            Text("Do you want to waive int'l duty free buffers to schedule recurrent training closer to a trip?")
                        }
                        
                        Toggle(isOn: $settingsManager.settings.waiveIntlBufferToAvoidPhaseInConflict) {
                            Text("Phase-in conflict: Waive int'l buffers?")
                            Text("Do you want to waive your int'l duty free buffers to prevent a phase-in conflict?")
                        }
                        
                        Toggle(isOn: $settingsManager.settings.waive1in10LegalityToAvoidPhaseInConflict) {
                            Text("Phase-in conflict: Waive 1-in-10?")
                            Text("Do you want to waive your 1-in-10 legality to prevent a phase-in conflict?")
                        }
                        
                        Toggle(isOn: $settingsManager.settings.protectMinDaysDueToCarryover) {
                            Text("Previous month carryover: Drop to protect min days off?")
                            Text("If you have carryover from last month, do you want activities dropped to protect min days off?")
                        }
                    }
                    Section {
#if os(iOS)
                        LabeledContent {
                            TextField("", text: $settingsManager.settings.employeeNumber, prompt: Text("Required"))
                        } label: {
                            Text("Employee #:")
                        }
#elseif os(macOS)
                        TextField("Employee #:", text: $settingsManager.settings.employeeNumber, prompt: Text("Required")).fixedSize()
#endif


                        HStack { 
                            Text("Month / Base / Equipment / Seat: ")
                            Text(bidManager.bidpackDescription).foregroundStyle(.secondary).foregroundStyle(.accent).bold()
                        }
                    } header: {
                        Text("Confirmation")
                    } footer: {
                        Text("Change seat on lines tab.")
                    }
                    Section {
                        Button("Submit Bid") {
                            guard bidManager.isStartInFuture || overrideExpiredBid else {
                                showExpiredBidPackAlert = true
                                return
                            }
                            
                            guard settingsManager.settings.employeeNumber != "" else {
                                showBlankEmployeeNumberAlert = true
                                return
                            }
                            do {
                                overrideExpiredBid = false
                                Task {
                                    try await settingsManager.save()
                                }
                                bid = try Bid(settings: settingsManager.settings, lineSelection: bidManager.lineNumbersOfBids)
                                showBidSubmitPage = true
                            }
                            catch (BidError.numberOfLinesBidError) {
                               showNumberOfLinesBidAlert = true
                            }
                            catch {
                                fatalError(error.localizedDescription)
                            }
                        }.buttonStyle(.bordered)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .font(.title)
                    } header: {
                        Text("Submit")
                    }.alert("Employee # is blank", isPresented: $showBlankEmployeeNumberAlert) {
                        Button("Dismiss") {
                            
                        }
                    } message: {
                        Text("The employee # field cannot be blank. Please enter your employee number above.")
                    }.textCase(nil).alert("Check # of bid lines", isPresented: $showNumberOfLinesBidAlert) {
                        Button("Dismiss") {
                            
                        }
                    } message: {
                        Text("The number of lines bid must be greater than 0 but less than 472. Check your bid.")
                    }.textCase(nil).alert("Old bidpack", isPresented: $showExpiredBidPackAlert) {
                        Button("Dismiss", role: .cancel) {
                            
                        }
                        Button("Override", role: .destructive) {
                            overrideExpiredBid = true
                        }
                    } message: {
                        Text("It appears this bidpack is old.") +
                        Text("\n\nToday's date is: \(Date(), format: .dateTime.day().month().year()).") +
                        Text("\nBidpack starts on: \(bidManager.bidpack.startDateLocal, format: .dateTime.day().month().year()).") +
                        Text("\n\nDismiss to load a new bid pack.") +
                        Text("\nor Override and resubmit.")
                    }.textCase(nil)
                }.sheet(isPresented: $showBidSubmitPage) {
                    VStack {
                        Button(webViewModel.title != "VIPS Monthly Bid Input" ? "Please Login" : "Submit Now") {
                            if let bid {
                                webViewModel.loadRequest(bid.createPostRequest())
                            }
                        }.disabled(webViewModel.title != "VIPS Monthly Bid Input").buttonStyle(.bordered).font(.title).padding()
                        WebView(webView: webViewModel.webView, title: $webViewModel.title).onAppear {
                            webViewModel.loadDefaultUrl()
                        }.padding()
                    }
                }
            }.navigationTitle("Submit")
        }.formStyle(.grouped)
    }
}
