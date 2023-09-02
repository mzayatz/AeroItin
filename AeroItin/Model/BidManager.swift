//
//  BidManager.swift
//  AeroItin
//
//  Created by Matt Zayatz on 9/1/23.
//

import Foundation

class BidManager: ObservableObject {
    static let filenames = [
        "2023_Sep_MD11_MEM_LINES",  // 0
        "2023_Sep_A300_MEM_LINES",  // 1
        "2023_Sep_B757_EUR_LINES",  // 2
        "2023_Sep_B757_MEM_LINES",  // 3
        "2023_Sep_B767_IND_LINES",  // 4
        "2023_Sep_B767_MEM_LINES",  // 5
        "2023_Sep_B767_OAK_LINES",  // 6
        "2023_Sep_B777_ANC_LINES",  // 7
        "2023_Sep_B777_MEM_LINES",  // 8
        "2023_Sep_MD11_ANC_LINES",  // 9
        "2023_Sep_MD11_LAX_LINES"   // 10
    ]
    
    static let urls = filenames.map {
        Bundle.main.url(forResource: $0, withExtension: testBidpackExtension)!
    }
    
    static let testingUrl = urls[0]
    
    static let testBidpackExtension = "asc"
    static let testBidpackUrl =
        Bundle.main.url(forResource: Bidpack.testBidpackFilename, withExtension: Bidpack.testBidpackExtension)!
    
    @Published var bidpack: Bidpack
    @Published var seat: Seat
    @Published var biddingLines: [Line]
    
    init(seat: Seat) {
        do {
            for url in BidManager.urls {
                try Bidpack(with: url)
            }
            try bidpack = Bidpack(with: BidManager.testingUrl)
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
        self.seat = seat
    }
    
    //MARK: User Intents
    func addLineToBid(line: Line) {
    
    }
    
    func removeLineFromBid() {
        
    }
    
    func clearBid() {
        
    }
    
    enum Seat {
        case captain
        case firstOfficer
    }
    
}
