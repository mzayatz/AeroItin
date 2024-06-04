//
//  TabViewLines.swift
//  AeroItin
//
//  Created by Matt Zayatz on 12/5/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct TabViewLines: View {
    @Environment(BidManager.self) private var bidManager: BidManager
    @State var showProgressView = false
    @State var searchText = ""
    @State var showResetAlert = false
    @State var showPilotAwardSheet = false
    @EnvironmentObject var webViewModel: WebViewModel
    @EnvironmentObject var settingsManager: SettingsManager

    var body: some View {
        @Bindable var bidManager = bidManager
        NavigationStack {
            ZStack(alignment: .bottom) {
                
                LineListScrollView {
                    if showProgressView {
                        ProgressView("Bidpack Loading... Please wait.")
                    }
                    LineListView()
                        .searchable(text:$bidManager.searchFilter, prompt: "IATA search")
                        .autocorrectionDisabled()
#if os(iOS)
                        .textInputAutocapitalization(.never)
#endif
                        .navigationTitle("\(bidManager.bidpackDescription)")
                    
                    
                }
                .zIndex(1)
                .toolbar {
                    BidToolbarContent(showResetAlert: $showResetAlert, showProgressView: $showProgressView, showPilotAwardSheet: $showPilotAwardSheet)
                }
                TripTextView()
                    .scaleEffect(bidManager.showTripText ? 1 : 0, anchor: .center)
                    .animation(.easeInOut, value: bidManager.showTripText)
                    .padding(.bottom)
                    .zIndex(2)
            }
        }
        .alert(isPresented: $showResetAlert) {
            Alert(
                title: Text("Clear bids and avoids?"),
                primaryButton: .cancel(),
                secondaryButton: .destructive(Text("Clear all"), action: bidManager.resetBid)
            )
        }
        .sheet(isPresented: $showPilotAwardSheet) {
            VStack {
                Button(webViewModel.title != "VIPS Monthly Bid Award" ? "Please Login" : "Get Awards") {
                    Task {
                        let pilots = await webViewModel.getPilotAwardsWith(webViewModel.awardRequest)
                        bidManager.bidpack.integratePilots(pilots, userEmployeeNumber: settingsManager.settings.employeeNumber)
                        showPilotAwardSheet = false
                    }
                }.disabled(webViewModel.title != "VIPS Monthly Bid Award").buttonStyle(.bordered).font(.title).padding()
                WebView(webView: webViewModel.webView, title: $webViewModel.title).onAppear {
                    webViewModel.awardRequest = webViewModel.createAwardRequestWith(bidManager.awardString)
                    webViewModel.loadAwardRequest()
                }.padding()
            }
        }
    }
    
    func LineListScrollView<Content: View>(@ViewBuilder content: @escaping () -> Content) -> some View {
        ScrollViewReader { proxy in
            if #available(iOS 17.0, macOS 14.0, *) {
                content()
                    .onChange(of: bidManager.scrollNow) {
                        withAnimation {
                            proxy.scrollTo(bidManager.bidpack[keyPath: bidManager.scrollSnap.associatedArrayKeypath].first?.id ?? UUID(), anchor: .topLeading)
                        }
                        bidManager.scrollNow = false
                    }
            } else {
                content()
                    .onChange(of: bidManager.scrollNow, perform: { _ in
                        withAnimation {
                            proxy.scrollTo(bidManager.bidpack[keyPath: bidManager.scrollSnap.associatedArrayKeypath].first?.id ?? UUID(), anchor: .topLeading)
                        }
                        bidManager.scrollNow = false
                    })
            }
        }
    }
}

//#Preview {
//    LinesTabView()
//}

