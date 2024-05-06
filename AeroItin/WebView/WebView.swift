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
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    weak var webView: WKWebView!
    
    @Binding var title: String
    
    func makeUIView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) { }
    
    func makeNSView(context: Context) -> WKWebView {
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) { }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.title = webView.title ?? ""
        }
        
    }
    
}

//#Preview {
//    WebView()
//}
