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
    @State var searchText = ""
    @State var showResetAlert = false
    @State var showFileImporter = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                LineListScrollView {
                    LineListView()
                        .searchable(text:$bidManager.searchFilter)
                        .autocorrectionDisabled()
#if os(iOS)
                        .textInputAutocapitalization(.never)
#endif
                        .navigationTitle(bidManager.bidpackDescription)
                        .fileImporter(
                            isPresented: $showFileImporter,
                            allowedContentTypes: [UTType.asc]) { result in
                                switch result {
                                case .success(let url):
                                    if url.startAccessingSecurityScopedResource() {
                                        bidManager.loadBidpackFromUrl(url)
                                    } else {
                                        
                                    }
                                    url.stopAccessingSecurityScopedResource()
                                case .failure(let error):
                                    print("failure")
                                }
                            }
                }
                .toolbar {
                    BidToolbarContent(showFileImporter: $showFileImporter, showResetAlert: $showResetAlert)
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
                    .onChange(of: bidManager.scrollSnap) {
                        withAnimation {
                            proxy.scrollTo(bidManager.bidpack[keyPath: bidManager.scrollSnap.associatedArrayKeypath].first?.id ?? "", anchor: .topLeading)
                        }
                    }
            } else {
                content()
                    .onChange(of: bidManager.scrollSnap, perform: { _ in
                        withAnimation {
                            proxy.scrollTo(bidManager.bidpack[keyPath: bidManager.scrollSnap.associatedArrayKeypath].first?.id ?? "", anchor: .topLeading)
                        }
                    })
            }
        }
    }
}


//#Preview {
//    LinesTabView()
//}
