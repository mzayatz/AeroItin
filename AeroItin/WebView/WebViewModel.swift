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
    static let awardUrl = URL(string: "https://pilot.fedex.com/vips-bin/vipscgi?webawd")!
    static let reviewUrl = URL(string: "https://pilot.fedex.com/vips-bin/vipscgi?webmbd")!
    
    var awardRequest = URLRequest(url: WebViewModel.awardUrl)
    var reviewRequest = URLRequest(url: WebViewModel.reviewUrl)
    
    private static let awardRegex = /(?<line>\d+) +(?<employee>\d+) +(?<senority>\d+) (?<name>[[:print:]]{1,20})(?<payOrFlex> *Pay| *Flex)?/
    
    private static let bidReviewRegex = /<TD NOWRAP>\s*([S?\d\s]+)\s*&nbsp;/
    
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
    
    func loadAwardRequest() {
        loadRequest(awardRequest)
    }
    
    @MainActor
    func getCurrentBidWith(_ urlRequest: URLRequest) async -> [String] {
        let cookies = await self.webView.configuration.websiteDataStore.httpCookieStore.allCookies()
        
        for cookie in cookies {
            URLSession.shared.configuration.httpCookieStorage?.setCookie(cookie)
        }
        
        let downloadTask = Task { () -> [String] in
            var bidLinesBuffer = [String]()
            //TODO: Enhance error handling here.
            if let data = try? await URLSession.shared.data(for: urlRequest) {
                guard let dataString = String(data: data.0, encoding: .utf8) else {
                    return bidLinesBuffer
                }
                let matches = dataString.matches(of: WebViewModel.bidReviewRegex)
                for match in matches {
                    let lineNumbers = match.1.split(separator: " ", omittingEmptySubsequences: true).map { String($0) }
                    bidLinesBuffer.append(contentsOf: lineNumbers)
                }
            }
            return bidLinesBuffer
        }
        let result = await downloadTask.result
        return (try? result.get()) ?? [String]()
    }
    
    @MainActor
    func getPilotAwardsWith(_ urlRequest: URLRequest) async -> [Pilot]  {
        let cookies = await self.webView.configuration.websiteDataStore.httpCookieStore.allCookies()
        
        for cookie in cookies {
            URLSession.shared.configuration.httpCookieStorage?.setCookie(cookie)
        }
        
        let downloadTask = Task { () -> [Pilot] in
            var awardsListBuffer = [Pilot]()
            //TODO: Enhance error handling here. It just returns an empty list of pilots
            if let data = try? await URLSession.shared.data(for: urlRequest) {
                guard let dataString = String(data: data.0, encoding: .utf8) else {
                    return awardsListBuffer
                }
                let matches = dataString.matches(of: WebViewModel.awardRegex)
                for match in matches {
                    awardsListBuffer.append(
                        Pilot(
                            name: String(match.name.components(separatedBy: ",").first ?? "Error!"),
                            employeeNumber: String(match.employee),
                            senority: String(match.senority),
                            awardedLine: String(match.line)
                        )
                    )
                }
            }
            return awardsListBuffer
        }
        let result = await downloadTask.result
        return (try? result.get()) ?? [Pilot]()
    }
    
    func createAwardRequestWith(_ awardString: String) -> URLRequest {
        return createRequestWith(string: awardString, url: WebViewModel.awardUrl)
    }
    
    func createReviewRequestWith(_ reviewString: String, url: URL) -> URLRequest {
        return createRequestWith(string: reviewString, url: url)
    }
    
    private func createRequestWith(string: String, url: URL) -> URLRequest {
        var items = URLComponents()
        items.queryItems = [URLQueryItem]()
        
        items.queryItems!.append(URLQueryItem(
            name: "n001",
            value: string
            )
        )
        let postUrl = url.appending(queryItems: items.queryItems!)
        var request = URLRequest(url: postUrl)
        request.httpMethod = "POST"
        request.httpBody = items.percentEncodedQuery?.data(using: .utf8)
        return request
    }
}

