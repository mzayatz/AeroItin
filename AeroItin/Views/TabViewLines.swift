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
    @State var showFileExporter = false
    @State var boop = false
    @State var showProgressView = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {

                LineListScrollView {
                    if showProgressView {
                        ProgressView("Bidpack Loading... Please wait.")
                    }
                    LineListView()
                        .searchable(text:$bidManager.searchFilter)
                        .autocorrectionDisabled()
#if os(iOS)
                        .textInputAutocapitalization(.never)
#endif
                        .navigationTitle(bidManager.bidpackDescription)
                        .fileExporter(isPresented: $showFileExporter, document: BidpackDocument(bidpack: bidManager.bidpack), contentType: .json) { result in
                            switch result {
                            case .success(let url):
                                print("success")
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                        
                        .fileImporter(
                            isPresented: $showFileImporter,
                            allowedContentTypes: [UTType.asc]) { result in
                                switch result {
                                case .success(let url):
//                                        guard let bidpackConents = try? String(contentsOf: url) else {
//                                            fatalError("crash!")
//                                        }
                                        Task {
                                            do {
                                                if url.startAccessingSecurityScopedResource() {
                                                    
                                                    showProgressView = true
                                                    await bidManager.loadBidpackWithString(try String(contentsOf: url))
                                                    showProgressView = false
                                                }
                                                url.stopAccessingSecurityScopedResource()
                                            }
                                            catch {
                                                fatalError(error.localizedDescription)
                                            }
                                        }
                                case .failure(let error):
                                    print("failure")
                                }
                            }
                }
                .toolbar {
                    BidToolbarContent(showFileImporter: $showFileImporter, showFileExporter: $showFileExporter, showResetAlert: $showResetAlert)
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

struct BidpackDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    
    var bidpack: Bidpack
    
    init(bidpack: Bidpack) {
        self.bidpack = bidpack
    }
    
    init(configuration: ReadConfiguration) {
        guard let data = configuration.file.regularFileContents else {
            fatalError("could not parse bidpack")
        }
        do {
            let bidpack = try JSONDecoder().decode(Bidpack.self, from: data)
            self.bidpack = bidpack
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        do {
            return FileWrapper(regularFileWithContents: try JSONEncoder().encode(bidpack))
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
    
    
}

//#Preview {
//    LinesTabView()
//}
