//
//  BidManager.swift
//  AeroItin
//
//  Created by Matt Zayatz on 9/1/23.
//

import Foundation
import SwiftUI

@MainActor
class BidManager: ObservableObject {
    static let filenames = [
        "2024_Jan_MD11_MEM_LINES",  // 0
        "2024_Jan_A300_MEM_LINES",  // 1
        "2024_Jan_B757_EUR_LINES",  // 2
        "2024_Jan_B757_MEM_LINES",  // 3
        "2024_Jan_B767_IND_LINES",  // 4
        "2024_Jan_B767_MEM_LINES",  // 5
        "2024_Jan_B767_OAK_LINES",  // 6
        "2024_Jan_B777_ANC_LINES",  // 7
        "2024_Jan_B777_MEM_LINES",  // 8
        "2024_Jan_MD11_ANC_LINES",  // 9
        "2024_Jan_MD11_LAX_LINES",  // 10
        "2023_Dec_MD11_MEM_LINES",  // 11
        "2023_Dec_A300_MEM_LINES",  // 12
        "2023_Dec_B757_EUR_LINES",  // 13
        "2023_Dec_B757_MEM_LINES",  // 14
        "2023_Dec_B767_IND_LINES",  // 15
        "2023_Dec_B767_MEM_LINES",  // 16
        "2023_Dec_B767_OAK_LINES",  // 17
        "2023_Dec_B777_ANC_LINES",  // 18
        "2023_Dec_B777_MEM_LINES",  // 19
        "2023_Dec_MD11_ANC_LINES",  // 20
        "2023_Dec_MD11_LAX_LINES",  // 10
        "2023_Nov_MD11_MEM_LINES",  // 11
        "2023_Nov_A300_MEM_LINES",  // 12
        "2023_Nov_B757_EUR_LINES",  // 13
        "2023_Nov_B757_MEM_LINES",  // 14
        "2023_Nov_B767_IND_LINES",  // 15
        "2023_Nov_B767_MEM_LINES",  // 16
        "2023_Nov_B767_OAK_LINES",  // 17
        "2023_Nov_B777_ANC_LINES",  // 18
        "2023_Nov_B777_MEM_LINES",  // 19
        "2023_Nov_MD11_ANC_LINES",  // 20
        "2023_Nov_MD11_LAX_LINES",  // 21
        "2023_Oct_MD11_MEM_LINES",  // 22
        "2023_Oct_A300_MEM_LINES",  // 23
        "2023_Oct_B757_EUR_LINES",  // 24
        "2023_Oct_B757_MEM_LINES",  // 25
        "2023_Oct_B767_IND_LINES",  // 26
        "2023_Oct_B767_MEM_LINES",  // 27
        "2023_Oct_B767_OAK_LINES",  // 28
        "2023_Oct_B777_ANC_LINES",  // 29
        "2023_Oct_B777_MEM_LINES",  // 30
        "2023_Oct_MD11_ANC_LINES",  // 31
        "2023_Oct_MD11_LAX_LINES"   // 32
    ]
    
    let settingsUrl = URL.documentsDirectory.appending(component: "settings.json")
    
    func loadSettings() async throws {
        let task = Task<Settings, Error> {
            guard let data = try? Data(contentsOf: settingsUrl) else {
                return Settings()
            }
            let settings = try JSONDecoder().decode(Settings.self, from: data)
            return settings
        }
        settings = try await task.value
    }
    
    func saveSettings() async throws {
        let task = Task {
            let data = try JSONEncoder().encode(settings)
            try data.write(to: settingsUrl)
        }
        _ = try await task.value
        
    }
    
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
    @Published var scrollSnap: Line.Flag = .neutral
    @Published var settings = Settings()
    
    var bidpackDescription: String {
        "\(bidpack.shortMonth) \(bidpack.year.suffix(2)) - \(bidpack.base.rawValue) \(bidpack.equipment.rawValue)\(bidpack.seat.abbreviatedSeat)"
    }
    
    init(url: URL, seat: Bidpack.Seat) {
        do {
//                        for url in BidManager.urls {
//                            try Bidpack(with: url, seat: seat)
//                        }
            let loadedBidpack = try Bidpack(with: url, seat: seat)
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
    
    convenience init(seat: Bidpack.Seat) {
        self.init(url: BidManager.testingUrl, seat: seat)
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
    func loadBidpackFromUrl(_ url: URL) {
        do {
            try bidpack = Bidpack(with: url, seat: .firstOfficer)
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
