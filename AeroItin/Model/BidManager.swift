//
//  BidManager.swift
//  AeroItin
//
//  Created by Matt Zayatz on 9/1/23.
//

import Foundation
import SwiftUI

class BidManager: ObservableObject {
    static let filenames = [
        "2023_Nov_MD11_MEM_LINES",  // 0
        "2023_Nov_A300_MEM_LINES",  // 1
        "2023_Nov_B757_EUR_LINES",  // 2
        "2023_Nov_B757_MEM_LINES",  // 3
        "2023_Nov_B767_IND_LINES",  // 4
        "2023_Nov_B767_MEM_LINES",  // 5
        "2023_Nov_B767_OAK_LINES",  // 6
        "2023_Nov_B777_ANC_LINES",  // 7
        "2023_Nov_B777_MEM_LINES",  // 8
        "2023_Nov_MD11_ANC_LINES",  // 9
        "2023_Nov_MD11_LAX_LINES"   // 10
    ]
    
    static let urls = filenames.map {
        Bundle.main.url(forResource: $0, withExtension: testBidpackExtension)!
    }
    
    static let testingUrl = urls[0]
    
    static let testBidpackExtension = "asc"
    static let testBidpackUrl =
        Bundle.main.url(forResource: Bidpack.testBidpackFilename, withExtension: Bidpack.testBidpackExtension)!
    
    @Published var bidpack: Bidpack
    @Published var selectedTripText: String? = nil
    @Published var searchFilter = ""
    
    var lines: [Line] {
        searchFilter.isEmpty ?  bidpack.lines : filterLines()
    }
    
    func filterLines() -> [Line] {
        let iatas = searchFilter.components(separatedBy: .whitespaces).filter { $0.count == 3 }.map { $0.lowercased() }
        
        guard !iatas.isEmpty else {
            return bidpack.lines
        }
        print(iatas)
        return bidpack.lines.filter { $0.layovers.contains { iatas.contains($0) } }
    }
    
    init(seat: Bidpack.Seat) {
        do {
//            for url in BidManager.urls {
//                try Bidpack(with: url, seat: seat)
//            }
            let loadedBidpack = try Bidpack(with: BidManager.testingUrl, seat: seat)
            bidpack = loadedBidpack
            dayWidth = (sensibleScreenWidth - lineLabelWidth) / CGFloat(Double(loadedBidpack.dates.count - 10))
            hourWidth = dayWidth / 24
            minuteWidth = hourWidth / 60
            secondWidth = minuteWidth / 60
            
            print(BidManager.testingUrl)
        }
        catch ParserError.sectionDividerNotFoundError {
            fatalError("SectionDividerNotFound Error... quitting.")
        }
        catch ParserError.tokenNotFoundError {
            fatalError("Token not found... quitting.")
        }
        catch {
            fatalError("Other error!\n\(error)")
        }
        
    }
    
    let lineHeight: CGFloat = 50
    let lineLabelWidth: CGFloat = 50
    
    let sensibleScreenWidth: CGFloat = 1000
    
    let dayWidth: CGFloat
    let hourWidth:  CGFloat
    let minuteWidth: CGFloat
    let secondWidth: CGFloat
    
//    let daySize: CGSize {
//        CGSize(width: dayWidth, height: lineHeight)
//    }
    
//    func lineLabelWidth(_ geometry: GeometryProxy) -> CGFloat {
//        dayWidth(geometry) * lineLabelWidthThingy
//    }
    
    //MARK: User Intents
    func resetBid() {
        bidpack.resetBid()
    }
    
    func moveLine(from source: IndexSet, toOffset destination: Int) {
        bidpack.moveLine(from: source, toOffset: destination)
    }
    
    func moveLineUpOne(line: Line) {
        guard let i = bidpack.lines.firstIndex(where: { $0.number == line.number }) else {
            return
        }
        bidpack.moveLine(from: IndexSet(integer: i), toOffset: i - 1)
    }
    
    func moveLineDownOne(line: Line) {
        guard let i = bidpack.lines.firstIndex(where: { $0.number == line.number }) else {
            return
        }
        bidpack.moveLine(from: IndexSet(integer: i), toOffset: i + 2)
    }
    
}
