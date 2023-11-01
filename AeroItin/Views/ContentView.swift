//
//  ContentView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 8/29/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
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
                    .onChange(of: bidManager.scrollSnap, perform: { newValue in
                        proxy.scrollTo(bidManager.bidpack[keyPath: newValue.associatedArrayKeypath].first?.id ?? "", anchor: .topLeading)
                    })
            }
        }
    }
}

#Preview {
    return ContentView().environmentObject(BidManager(seat: .firstOfficer))
}
