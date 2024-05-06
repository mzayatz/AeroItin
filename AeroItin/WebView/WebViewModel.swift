//
//  WebViewModel.swift
//  AeroItin
//
//  Created by Matt Zayatz on 12/1/23.
//

import SwiftUI
import WebKit

class WebViewModel: ObservableObject {
    @Published var webView = WKWebView()
    @Published var title = ""
    
    let initialUrlString = "https://pilot.fedex.com/vips-bin/vipscgi?webmtb"
    
    func loadUrlString(_ string: String) {
        guard let url = URL(string: string) else {
            return
        }
        webView.load(URLRequest(url: url))
    }
   
    func loadDefaultUrl() {
        loadUrlString(initialUrlString)
    }
   
    func loadRequest(_ urlRequest: URLRequest) {
        webView.load(urlRequest)
    }
}
