//
//  WebViewModel.swift
//  AeroItin
//
//  Created by Matt Zayatz on 12/1/23.
//

import SwiftUI
import WebKit

class WebViewModel: ObservableObject {
    weak var webView: WKWebView?

    var title: String? {
        webView?.title
    }
    
    func loadUrlString(_ string: String) {
        guard let url = URL(string: string) else {
            return
        }
        webView?.load(URLRequest(url: url))
    }
    
}
