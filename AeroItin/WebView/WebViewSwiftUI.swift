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
        
    var body: some View {
        NavigationStack {
            WebView(viewModel: webViewModel)
                .onAppear {
                    webViewModel.loadDefaultUrl()
                }
        }
    }
}

//#Preview {
//    WebViewStack()
//}
