//
//  WebViewStack.swift
//  AeroItin
//
//  Created by Matt Zayatz on 11/29/23.
//

import SwiftUI

struct WebViewSwiftUI: View {
    @EnvironmentObject var bidManager: BidManager
    @StateObject var webViewModel = WebViewModel()
    
    let startUrl = URL(string: "https://pilot.fedex.com")!
    
    var body: some View {
        NavigationStack {
            WebView(url: startUrl, viewModel: webViewModel)
                .navigationTitle(bidManager.bidpackDescription)
        }
    }
}

//#Preview {
//    WebViewStack()
//}
