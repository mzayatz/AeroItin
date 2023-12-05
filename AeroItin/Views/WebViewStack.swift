//
//  WebViewStack.swift
//  AeroItin
//
//  Created by Matt Zayatz on 11/29/23.
//

import SwiftUI

struct WebViewStack: View {
    
    @StateObject var webViewModel = WebViewModel()
    
    let startUrl = URL(string: "https://pilot.fedex.com")!
    
    var body: some View {
        VStack {
            Button("fedex") {
                webViewModel.loadUrlString("https://pilot.fedex.com")
            }
            WebView(url: startUrl, viewModel: webViewModel)
        }
    }
}

#Preview {
    WebViewStack()
}
