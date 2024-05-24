//
//  TabViewLines.swift
//  AeroItin
//
//  Created by Matt Zayatz on 12/5/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct TabViewLines: View {
    @EnvironmentObject var bidManager: BidManager
    @State var showProgressView = false
    @State var searchText = ""
    @State var showResetAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {

                LineListScrollView {
                    if showProgressView {
                        ProgressView("Bidpack Loading... Please wait.")
                    }
                    LineListView(
                        bids: $bidManager.bidpack.bids,
                        lines: bidManager.filteredLines,
                        avoids: $bidManager.bidpack.avoids,
                        dates: bidManager.bidpack.dates,
                        timeZone: bidManager.bidpack.base.timeZone,
                        transferLine: bidManager.transferLine,
                        selectedTripText: $bidManager.selectedTripText,
                        sortDescending: $bidManager.bidpack.sortDescending,
                        bookmark: $bidManager.bidpack.bookmark
                    )
                        .searchable(text:$bidManager.searchFilter, prompt: "IATA search")
                        .autocorrectionDisabled()
#if os(iOS)
                        .textInputAutocapitalization(.never)
#endif
                        .navigationTitle("\(bidManager.bidpackDescription)")

                        
                                }
                .toolbar {
                    BidToolbarContent(showResetAlert: $showResetAlert, showProgressView: $showProgressView)
                }
                if bidManager.selectedTripText != nil {
                    TripTextView(selectedTripText: $bidManager.selectedTripText)
                        .transition(AnyTransition.move(edge: .bottom))
                }
            }
        }.alert(isPresented: $showResetAlert) {
            Alert(
                title: Text("Clear bids and avoids?"),
                primaryButton: .cancel(),
                secondaryButton: .destructive(Text("Clear all"), action: bidManager.resetBid)
            )
        }
    }
    
    func LineListScrollView<Content: View>(@ViewBuilder content: @escaping () -> Content) -> some View {
        ScrollViewReader { proxy in
            if #available(iOS 17.0, macOS 14.0, *) {
                content()
                    .onChange(of: bidManager.scrollNow) {
                        withAnimation {
                            proxy.scrollTo(bidManager.bidpack[keyPath: bidManager.scrollSnap.associatedArrayKeypath].first?.id ?? "", anchor: .topLeading)
                        }
                        bidManager.scrollNow = false
                    }
            } else {
                content()
                    .onChange(of: bidManager.scrollNow, perform: { _ in
                        withAnimation {
                            proxy.scrollTo(bidManager.bidpack[keyPath: bidManager.scrollSnap.associatedArrayKeypath].first?.id ?? "", anchor: .topLeading)
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
