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
    let awardUrl = URL(string:"https://pilot.fedex.com/vips-bin/vipscgi?webawd")!
    
    private static let awardRegex = /(?<line>\d+) +(?<employee>\d+) +(?<senority>\d+) (?<name>[[:print:]]{1,20})(?<payOrFlex> *Pay| *Flex)?/
    
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
    
    @MainActor
    func getCurrentHtml() async -> [Pilot]  {
        let cookies = await self.webView.configuration.websiteDataStore.httpCookieStore.allCookies()
        
        for cookie in cookies {
            URLSession.shared.configuration.httpCookieStorage?.setCookie(cookie)
        }
        
        let downloadTask = Task { () -> [Pilot] in
            var awardsListBuffer = [Pilot]()
            //TODO: Enhance error handling here. It just returns an empty list of pilots
            if let data = try? await URLSession.shared.data(for: createAwardRequest(month: "FEB", year: "24", base: .mem, equipment: .b777, seat: .firstOfficer)) {
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
    
    private func createAwardRequestString(month: String, year: String, base: Bidpack.Base, equipment: Bidpack.Equipment, seat: Bidpack.Seat) -> String {
        return "\(month)\(year)+\(base.rawValue)+\(equipment.rawValue)\(seat.abbreviatedSeat)+Monthly+Bid+Awards+by+Line"
    }
    
    func createAwardRequest(month: String, year: String, base: Bidpack.Base, equipment: Bidpack.Equipment, seat: Bidpack.Seat) -> URLRequest{
        
        var items = URLComponents()
        items.queryItems = [URLQueryItem]()
        
        items.queryItems!.append(URLQueryItem(
            name: "n001",
            value: createAwardRequestString(
                month: month, year: year, base: base, equipment: equipment, seat: seat
            )
        ))
        let postUrl = awardUrl.appending(queryItems: items.queryItems!)
        var request = URLRequest(url: postUrl)
        request.httpMethod = "POST"
        request.httpBody = items.percentEncodedQuery?.data(using: .utf8)
        return request
    }
}

