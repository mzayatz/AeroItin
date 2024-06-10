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
    @State var showPilotAwardSheet = false
    @State var showVerifyBidSheet = false
    @State var showAlert = false
    @State var alertType: AlertType? = nil
    
    @State private var currentVipsBid = [String]()
    
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
                    BidToolbarContent(alertType: $alertType, showProgressView: $showProgressView, showPilotAwardSheet: $showPilotAwardSheet, showVerifyBidSheet: $showVerifyBidSheet, showAlert: $showAlert
                    )
                }
                TripTextView()
                    .scaleEffect(bidManager.showTripText ? 1 : 0, anchor: .center)
                    .animation(.easeInOut, value: bidManager.showTripText)
                    .padding(.bottom)
                    .zIndex(2)
            }
        }
        .alert(isPresented: $showAlert) {
            switch alertType {
            case .resetAlert:
                Alert(
                    title: Text("Clear bids and avoids?"),
                    primaryButton: .cancel(),
                    secondaryButton: .destructive(Text("Clear all"), action: bidManager.resetBid)
                )
            case .bidOkAlert:
                Alert(
                    title: Text("Bid verified OK!"),
                    message: Text("Latest bid downloaded in VIPS and it matches the bid in this app.")
                )
            case .bidErrorAlert:
                Alert(
                    title: Text("Warning! Bid Error!"),
                    message: Text("Bid downloaded from VIPS does NOT match current bid. Tap \"Load VIPS\" to load VIPS bid into the app."),
                    primaryButton: .cancel(),
                    secondaryButton: .destructive(Text("Load VIPS")) {
                        //FIXME: Some sort of error handling if vipsBid contains a line not in our lines databaseß
                        let _ = bidManager.replaceBidWith(currentVipsBid)
                        currentVipsBid.removeAll()
                        Task {
                            //FIXME: Error handling?
                            try? await bidManager.saveSnapshot()
                        }
                    }
                )
            case .none:
                Alert(title: Text("Unknown error..."))
            }
        }
        .sheet(isPresented: $showPilotAwardSheet) {
            VStack {
                Button(webViewModel.title != "VIPS Monthly Bid Award" ? "Please Login" : "Get Awards") {
                    Task {
                        let pilots = await webViewModel.getPilotAwardsWith(webViewModel.awardRequest)
                        bidManager.bidpack.integratePilots(pilots, userEmployeeNumber: settingsManager.settings.employeeNumber)
                        showPilotAwardSheet = false
                        Task {
                            //FIXME: Some sort of error handling?
                            try? await bidManager.saveSnapshot()
                        }
                    }
                }.disabled(webViewModel.title != "VIPS Monthly Bid Award").buttonStyle(.bordered).font(.title).padding()
                WebView(webView: webViewModel.webView, title: $webViewModel.title).onAppear {
                    webViewModel.awardRequest = webViewModel.createAwardRequestWith(bidManager.awardString)
                    webViewModel.loadAwardRequest()
                }.padding()
            }
        }
        .sheet(isPresented: $showVerifyBidSheet) {
            VStack {
                Button(webViewModel.title != "VIPS Monthly Bid Review" ? "Please Login" : "Check bid") {
                    Task {
                        currentVipsBid = await webViewModel.getCurrentBidWith(webViewModel.reviewRequest)
                        var bidVerified = true
                        let lineNumbersOfBids = bidManager.lineNumbersOfBids
                        if currentVipsBid.count == bidManager.bidpack.bids.count {
                            for i in currentVipsBid.indices {
                                if currentVipsBid[i] != lineNumbersOfBids[i] {
                                    bidVerified = false
                                    break
                                }
                            }
                        } else {
                            bidVerified = false
                            print("VIPS: \(currentVipsBid.count) - App: \(lineNumbersOfBids.count)")
                        }

                        if bidVerified {
                            alertType = .bidOkAlert
                            showAlert = true
                        } else {
                            alertType = .bidErrorAlert
                            showAlert = true
                        }
                    }
                    showVerifyBidSheet = false
                }.disabled(webViewModel.title != "VIPS Monthly Bid Review").buttonStyle(.bordered).font(.title).padding()
                WebView(webView: webViewModel.webView, title: $webViewModel.title).onAppear {
                    if settingsManager.settings.employeeNumber != "" {
                        let url = URL(string: "https://pilot.fedex.com/vips-bin/vipscgi?webmbd?\(settingsManager.settings.employeeNumber)?\(bidManager.shortMonthAndYear)?AAAA")!
                        let request = URLRequest(url: url)
                    
                        webViewModel.reviewRequest = request
                        webViewModel.loadRequest(URLRequest(url: WebViewModel.reviewUrl))
                    }
                    
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
    
    enum AlertType {
        case resetAlert
        case bidOkAlert
        case bidErrorAlert
    }
}

//#Preview {
//    LinesTabView()
//}

