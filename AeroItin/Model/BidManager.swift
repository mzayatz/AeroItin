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
    
    
    static let urls = filenames.map {
        Bundle.main.url(forResource: $0, withExtension: bidpackExtension)!
    }
    static let testingUrl = urls[0]
    static let bidpackExtension = "asc"
    
    let lineHeight: CGFloat = 50
    let lineLabelWidth: CGFloat = 50
    let sensibleScreenWidth: CGFloat = 1000
    var dayWidth: CGFloat
    var hourWidth:  CGFloat
    var minuteWidth: CGFloat
    var secondWidth: CGFloat
    var settingsUrl = URL.documentsDirectory.appending(component: "settings.json")
    var snapshotUrlFragment = URL.documentsDirectory.appending(component: "snapshot.json")
    
    @Published var bidpack: Bidpack
    @Published var selectedTripText: String? = nil
    @Published var searchFilter = ""
    @Published var scrollSnap: Line.Flag = .neutral
    @Published var settings = Settings()
    
    var bidpackDescription: String {
        guard bidpack.year != "1971" else {
            return "No Bidpack Loaded"
        }
        return "\(bidpack.shortMonth) \(bidpack.year.suffix(2)) - \(bidpack.base.rawValue) \(bidpack.equipment.rawValue)\(bidpack.seat.abbreviatedSeat)"
    }
    
    init() {
        bidpack = Bidpack()
        dayWidth = 0
        hourWidth = 0
        minuteWidth = 0
        secondWidth = 0
    }
    
    init(text: String, seat: Bidpack.Seat) async {
        do {
//            for url in BidManager.urls {
//                try Bidpack(with: url, seat: seat)
//            }
            let loadedBidpack = try await Bidpack(text: text , seat: seat)
            bidpack = loadedBidpack
            dayWidth = (sensibleScreenWidth - lineLabelWidth) / CGFloat(Double(loadedBidpack.dates.count - 7))
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
    
    convenience init(seat: Bidpack.Seat) async {
        await self.init(text: try! String(contentsOf: BidManager.testingUrl), seat: seat)
    }
    
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
            settings.seat = bidpack.seat
            let data = try JSONEncoder().encode(settings)
            try data.write(to: settingsUrl)
        }
        _ = try await task.value
        
    }
    
    var suggestedBidFileName: String {
        return bidpack.year == "1971" ? "no bidpack loaded" :
            "\(DateFormatter.fileTimeStamp)-\(bidpack.besWithBidMonth)"
    }
    
//    func saveSnapshot() async throws {
//        let task = Task {
//            let data = try JSONEncoder().encode(bidpack)
//            try data.write(to: snapshotUrlFragment)
//        }
//        _ = try await task.value
//    }
//    
//    func loadSnapshot() async throws {
//        let task = Task<Bidpack, Error> {
//            guard let data = try? Data(contentsOf: snapshotUrlFragment) else {
//                return Bidpack()
//            }
//            let bidpack = try JSONDecoder().decode(Bidpack.self, from: data)
//            return bidpack
//        }
//        bidpack = try await task.value
//    }
    
    func loadSnapshot(data: Data) async throws {
        let task = Task<Bidpack, Error> {
            let bidpack = try JSONDecoder().decode(Bidpack.self, from: data)
            return bidpack
        }
        bidpack = try await task.value
    }
    
    //MARK: User Intents
    func loadBidpackWithString(_ text: String) async {
        do {
            try bidpack = await Bidpack(text: text, seat: settings.seat)
            dayWidth = (sensibleScreenWidth - lineLabelWidth) / CGFloat(Double(bidpack.dates.count - 7))
            hourWidth = dayWidth / 24
            minuteWidth = hourWidth / 60
            secondWidth = minuteWidth / 60
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
