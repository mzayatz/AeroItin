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
        "2023_Oct_MD11_MEM_LINES",  // 0
        "2023_Oct_A300_MEM_LINES",  // 1
        "2023_Oct_B757_EUR_LINES",  // 2
        "2023_Oct_B757_MEM_LINES",  // 3
        "2023_Oct_B767_IND_LINES",  // 4
        "2023_Oct_B767_MEM_LINES",  // 5
        "2023_Oct_B767_OAK_LINES",  // 6
        "2023_Oct_B777_ANC_LINES",  // 7
        "2023_Oct_B777_MEM_LINES",  // 8
        "2023_Oct_MD11_ANC_LINES",  // 9
        "2023_Oct_MD11_LAX_LINES"   // 10
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
    
    init(seat: Bidpack.Seat) {
        do {
//            for url in BidManager.urls {
//                try Bidpack(with: url, seat: seat)
//            }
            try bidpack = Bidpack(with: BidManager.testingUrl, seat: seat)
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
    
    func dayWidth(_ geometry: GeometryProxy) -> CGFloat {
        geometry.size.width > 1000 ? (geometry.size.width - lineLabelWidth) / CGFloat(Double(bidpack.dates.count - 7)) :
        (geometry.size.width - lineLabelWidth) / CGFloat(Double(bidpack.dates.count - 10))
    }
        
    func hourWidth(_ geometry: GeometryProxy) -> CGFloat {
        dayWidth(geometry) / 24
    }
    
    func minuteWidth(_ geometry: GeometryProxy) -> CGFloat {
        hourWidth(geometry) / 60
    }
    
    func secondWidth(_ geometry: GeometryProxy) -> CGFloat {
        minuteWidth(geometry) / 60
    }
    
    func daySize(_ geometry: GeometryProxy) -> CGSize {
        CGSize(width: dayWidth(geometry), height: lineHeight)
    }
    
//    func lineLabelWidth(_ geometry: GeometryProxy) -> CGFloat {
//        dayWidth(geometry) * lineLabelWidthThingy
//    }
    
    //MARK: User Intents
//    func bidLine(line: Line) {
//        bidpack.setFlag(for: line, flag: .bid)
//    }
//    
//    func resetLine(line: Line) {
//        bidpack.setFlag(for: line, flag: .neutral)
//    }
//    
//    func avoidLine(line: Line) {
//        bidpack.setFlag(for: line, flag: .avoid)
//    }
    
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
