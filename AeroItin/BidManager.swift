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
    static let testingUrl = urls[8]
    static let bidpackExtension = "asc"
    
    let lineHeight: CGFloat = 35
    let lineLabelWidth: CGFloat = 60
    let sensibleScreenWidth: CGFloat = 1000
    
    var dayWidth: CGFloat {
        (sensibleScreenWidth - lineLabelWidth) / CGFloat(Double(bidpack.dates.count - 5))
    }
    var hourWidth: CGFloat  {
        dayWidth / 24
    }
    var minuteWidth: CGFloat {
        hourWidth / 60
    }
    var secondWidth: CGFloat {
        minuteWidth / 60
    }
    
    var dateCount: Int {
        bidpack.dates.count
    }
    
    var settingsUrl = URL.documentsDirectory.appending(component: "settings.json")
    var snapshotUrlFragment = URL.documentsDirectory.appending(component: "snapshot.json")
    
    @Published var bidpack: Bidpack {
        didSet {
            Task {
                do {
                    try await saveSnapshot()
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
        }
    }
    @Published var selectedTripText: String? = nil
    @Published var searchFilter = ""
    @Published var debouncedSearchFilter = ""
    @Published var scrollSnap: Line.Flag = .neutral
    @Published var settings = Settings()
    @Published var filterDeadheads = false
    @Published var avoidedDateComponents = Set<DateComponents>() {
        didSet {
            avoidedDates = avoidedDateComponents.compactMap {
                Calendar.localCalendarFor(timeZone: bidpack.base.timeZone).date(from: $0)
            }
            bidpack.dates = bidpack.dates.map { $0.resetCategory() }
            for date in avoidedDates {
                if let i = bidpack.dates.firstIndex(where: {
                    $0.calendarDate == date
                }) {
                    bidpack.dates[i].category = .avoid
                }
            }
        }
    }
    @Published var avoidedDates = [Date]()
    
    
    
    var bidpackDescription: String {
        guard bidpack.year != "1971" else {
            return "No Bidpack Loaded"
        }
        return "\(bidpack.shortMonth) \(bidpack.year.suffix(2)) - \(bidpack.base.rawValue) \(bidpack.equipment.rawValue)\(bidpack.seat.abbreviatedSeat)"
    }
    
    var filteredLines: [Line] {
        return bidpack.lines.filter { line in
            let isCategoryFiltered = !bidpack.categoryFilter.contains(line.category)
            let isDeadheadFiltered = !filterDeadheads || line.hasDeadhead
            let isIATAMatched = line.layovers.contains { searchIatas.contains($0) }
            return (searchIatas.isEmpty || isIATAMatched) && isCategoryFiltered && isDeadheadFiltered
        }.filter { line in
            let conflicts = line.trips.contains { trip in
                avoidedDates.contains { avoidedDate in
                    trip.startDate <= avoidedDate && trip.endDate >= avoidedDate
                }
            }
            // If there are conflicts, filter out this line
            return !conflicts
        }
    }
    
    var searchIatas: [String] {
        return debouncedSearchFilter.lowercased().components(separatedBy: .whitespaces).filter { $0.count == 3 }
    }
    
    init() {
        bidpack = Bidpack()
        $searchFilter
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .assign(to: &$debouncedSearchFilter)
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
    
    func saveSnapshot() async throws {
        let task = Task {
            let data = try JSONEncoder().encode(bidpack)
            try data.write(to: snapshotUrlFragment)
        }
        _ = try await task.value
    }
    
    func loadSnapshot() async throws {
        bidpack = try await makeLoadSnapshotTask().value
    }
    
    func loadSnapshot(data: Data) async throws {
        bidpack = try await makeLoadSnapshotTask(data: data).value
    }
    
    private func makeLoadSnapshotTask(data: Data? = nil) throws -> Task<Bidpack, Error> {
        let task = Task<Bidpack, Error> {
            let bidpack = try JSONDecoder().decode(Bidpack.self, from: data ?? Data(contentsOf: snapshotUrlFragment))
            return bidpack
        }
        return task
    }

    
    //MARK: User Intents
    func loadBidpackWithString(_ text: String) async {
        do {
            try bidpack = await Bidpack(text: text, seat: settings.seat)
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

extension BidPeriodDate {
    var color: Color {
        switch self.category {
        case .normal:
            return isWeekend ? .secondary.opacity(0.25) : .clear
        case .avoid:
            return .red.opacity(0.25)
        }
    }
}
