//
//  WebView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 11/21/23.
//

#if os(iOS)
typealias WebViewRepresentable = UIViewRepresentable
#elseif os(macOS)
typealias WebViewRepresentable = NSViewRepresentable
#endif

import SwiftUI
import WebKit

struct WebView: WebViewRepresentable {
   
    @ObservedObject var viewModel: WebViewModel
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        viewModel.webView = webView
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) { }
}

//#Preview {
//    WebView()
//}
