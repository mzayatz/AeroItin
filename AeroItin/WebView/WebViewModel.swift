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
    
    private let awardRegex = /^(?<lineNumber>\d+) +(?<employeeNumber>\d+) +(?<pilotSenority>\d+) (?<pilotName>[[:print:]]{1,20})(?<payOrFlex> *Pay| *Flex)?/
    
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
    
    private func createAwardRequestString(month: String, year: String, base: Bidpack.Base, equipment: Bidpack.Equipment, seat: Bidpack.Seat) -> String {
        print("\(month)\(year)+\(base.rawValue)+\(equipment.rawValue)\(seat.abbreviatedSeat)+Monthly+Bid+Awards+by+Line")
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

