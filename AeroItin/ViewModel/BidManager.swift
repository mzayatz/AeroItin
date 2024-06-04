//
//  BidManager.swift
//  AeroItin
//
//  Created by Matt Zayatz on 9/1/23.
//

import Foundation
import SwiftUI

@Observable
class BidManager {
    static let urls = filenames.map {
        Bundle.main.url(forResource: $0, withExtension: bidpackExtension)!
    }
    static let testingUrl = urls[8]
    static let bidpackExtension = "asc"
    
    static let snapshotUrlFragment = URL.documentsDirectory.appending(component: "snapshot.json")
    
    var bidpack: Bidpack
    var bookmark: Int? = nil

    var selectedTripText: String? = nil
    var showTripText = false
    var searchFilter = ""
//    @Published var debouncedSearchFilter = ""
    var scrollSnap: Line.Flag = .neutral
    var scrollNow = false
    var filterDeadheads = false
    var avoidedDateComponents = Set<DateComponents>() {
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
    var avoidedDates = [Date]()
    
    var sortLinesBy: SortOptions = .number {
        didSet {
            sortLines()
        }
    }
    
    var sortDescending = false {
        didSet {
            sortLines()
        }
    }
    
    private(set) var categoryFilter: Set<Line.Category> = [.reserve, .secondary]

    var showReserveLines = false {
        didSet {
            _ = showReserveLines ? categoryFilter.remove(.reserve) : categoryFilter.update(with: .reserve)
        }
    }
    
    var showSecondaryLines = false {
        didSet {
            _ = showSecondaryLines ? categoryFilter.remove(.secondary) : categoryFilter.update(with: .secondary)
        }
    }
    
    var showRegularLines = true {
        didSet {
            _ = showRegularLines ? categoryFilter.remove(.regular) : categoryFilter.update(with: .regular)
        }
    }
    
    private var comparator: KeyPathComparator<Line> {
        sortLinesBy.getKeyPath()
    }
    
    var bidpackDescription: String {
        guard bidpack.year != "1971" else {
            return "No Bidpack Loaded"
        }
        return "\(shortMonth) \(bidpack.year.suffix(2)) - \(bidpack.base.rawValue) \(bidpack.equipment.rawValue)\(bidpack.seat.abbreviatedSeat)"
    }
    
    var dateRange: Range<Date> {
        bidpack.startDateLocal..<bidpack.endDateLocal.addingTimeInterval(.day)
    }
    
    var lineNumbersOfBids: [String] {
        bidpack.bids.map { $0.number }
    }
    
    var isStartInFuture: Bool {
        bidpack.startDateLocal.timeIntervalSinceNow > 0
    }
    
    var filteredLines: [Line] {
        return bidpack.lines.filter { line in
            let isCategoryFiltered = !categoryFilter.contains(line.category)
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
        return searchFilter.lowercased().components(separatedBy: .whitespaces).filter { $0.count == 3 }
    }
    
    init() {
        let localBidpack = Bidpack()
        bidpack = localBidpack
//        $searchFilter
//            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
//            .assign(to: &$debouncedSearchFilter)
    }
    
    var suggestedBidFileName: String {
        return bidpack.year == "1971" ? "no bidpack loaded" :
            "\(DateFormatter.fileTimeStamp)-\(besWithBidMonth)"
    }
    
    var besWithBidMonth: String {
        "\(shortMonth) \(bidpack.year.suffix(2)) (" + bes + ")"
    }
    
    var bes: String {
        bidpack.base.rawValue + bidpack.equipment.rawValue + bidpack.seat.abbreviatedSeat
    }
    
    var awardString: String {
        "\(shortMonth.uppercased())\(bidpack.year.suffix(2))+\(bidpack.base.rawValue)+\(bidpack.equipment.rawValue)\(bidpack.seat.abbreviatedSeat)+Monthly+Bid+Awards+by+Line"
    }
    
    var shortMonth: String {
        let monthDictionary = [
            "JANUARY": "Jan",
            "FEBRUARY": "Feb",
            "MARCH": "Mar",
            "APRIL": "Apr",
            "MAY": "May",
            "JUNE": "Jun",
            "JULY": "Jul",
            "AUGUST": "Aug",
            "SEPTEMBER": "Sep",
            "OCTOBER": "Oct",
            "NOVEMBER": "Nov",
            "DECEMBER": "Dec"
        ]
        return monthDictionary[bidpack.month] ?? ""
    }
    
    func saveSnapshot() async throws {
        let task = Task {
            let data = try JSONEncoder().encode(bidpack)
            try data.write(to: BidManager.snapshotUrlFragment)
        }
        _ = try await task.value
        print("saved")
    }
    
    func sortLines() {
        bidpack.lines.sort(using: comparator)
        if sortDescending {
            bidpack.lines.reverse()
        }
    }
    
    func loadSnapshot() async throws {
        bidpack = try await makeLoadSnapshotTask().value
    }
    
    func loadSnapshot(data: Data) async throws {
        bidpack = try await makeLoadSnapshotTask(data: data).value
    }
    
    private func makeLoadSnapshotTask(data: Data? = nil) throws -> Task<Bidpack, Error> {
        print("loaded")
        let task = Task<Bidpack, Error> {
            let bidpack = try JSONDecoder().decode(Bidpack.self, from: data ?? Data(contentsOf: BidManager.snapshotUrlFragment))
            return bidpack
        }
        return task
    }

    
    //MARK: User Intents
    func loadBidpackWithString(_ text: String, seat: Bidpack.Seat) async {
        do {
            try bidpack = await Bidpack(text: text, seat: seat)
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
    
    func transferLine(line: Line, action: TransferActions) {
        let keyPaths = action.getKeyPaths()
        guard let i = bidpack[keyPath: keyPaths.source].firstIndex(where: { $0.number == line.number }) else {
            return
        }
        switch action {
        case .fromBidsToLines:
            bidpack[keyPath: keyPaths.destination].insert(bidpack[keyPath: keyPaths.source].remove(at: i), at: bidpack[keyPath: keyPaths.destination].startIndex)
        case .fromLinesToBids:
            if let bookmark,
               bookmark < bidpack.bids.endIndex && bookmark >= bidpack.bids.startIndex {
                if bookmark == bidpack.bids.startIndex {
                    bidpack[keyPath: keyPaths.destination].insert(bidpack[keyPath: keyPaths.source].remove(at: i), at: bidpack.bids.startIndex)
                } else if self.bookmark == bidpack.bids.endIndex - 1 {
                    bidpack[keyPath: keyPaths.destination].append(bidpack[keyPath: keyPaths.source].remove(at: i))
                    self.bookmark = bidpack.bids.endIndex - 1
                } else {
                    bidpack[keyPath: keyPaths.destination].insert(bidpack[keyPath: keyPaths.source].remove(at: i), at: bookmark)
                    self.bookmark = bookmark + 1
                }
            } else {
                bidpack[keyPath: keyPaths.destination].append(bidpack[keyPath: keyPaths.source].remove(at: i))
            }
        default:
            bidpack[keyPath: keyPaths.destination].append(bidpack[keyPath: keyPaths.source].remove(at: i))
        }
        Task {
            //TODO: Error handling
            try? await saveSnapshot()
        }
    }
    
    enum TransferActions: Codable {
        case fromLinesToBids
        case fromLinesToAvoids
        case fromBidsToLines
        case fromBidsToAvoids
        case fromAvoidsToLines
        case fromAvoidsToBids
        
        func getKeyPaths() -> (source: WritableKeyPath<Bidpack, [Line]>, destination: WritableKeyPath<Bidpack, [Line]>) {
            switch self {
            case .fromLinesToBids:
                return (\.lines, \.bids)
            case .fromLinesToAvoids:
                return (\.lines, \.avoids)
            case .fromBidsToLines:
                return (\.bids, \.lines)
            case .fromBidsToAvoids:
                return (\.bids, \.avoids)
            case .fromAvoidsToLines:
                return (\.avoids, \.lines)
            case .fromAvoidsToBids:
                return (\.avoids, \.bids)
            }
        }
    }
    enum SortOptions: String, CaseIterable, Codable {
        case number = "Number"
        case creditHours = "Credit hours"
        case blockHours = "Block hours"
        case landings = "Landings"
        case daysOff = "Days off"
        case dutyPeriods = "Duty periods"
        case pilotSeniority = "Pilot seniority"
        
        func getKeyPath() -> KeyPathComparator<Line> {
            switch self {
            case .number:
                return KeyPathComparator(\Line.number)
            case .creditHours:
                return KeyPathComparator(\Line.summary.creditHours)
            case .blockHours:
                return KeyPathComparator(\Line.summary.blockHours)
            case .landings:
                return KeyPathComparator(\Line.summary.landings)
            case .daysOff:
                return KeyPathComparator(\Line.summary.daysOff)
            case .dutyPeriods:
                return KeyPathComparator(\Line.summary.dutyPeriods)
            case .pilotSeniority:
                return KeyPathComparator(\Line.pilot?.senority)
            }
        }
        
        var symbol: String {
            switch self {
            case .number:
                return "number"
            case .creditHours:
                return "creditcard"
            case .blockHours:
                return "clock"
            case .landings:
                return "airplane.arrival"
            case .daysOff:
                return "sunglasses.fill"
            case .dutyPeriods:
                return "mappin.and.ellipse"
            case .pilotSeniority:
                return "person"
            }
        }
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

extension Line.Flag {
    var associatedArrayKeypath: WritableKeyPath<Bidpack, [Line]> {
        switch self {
        case .avoid:
            return \Bidpack.avoids
        case .bid:
            return \Bidpack.bids
        case .neutral:
            return \Bidpack.lines
        }
    }
    
    var plusTransferAction: BidManager.TransferActions {
        switch self {
        case .avoid:
            return .fromAvoidsToBids
        case .bid:
            return .fromBidsToLines
        case .neutral:
            return .fromLinesToBids
        }
    }
    
    var minusTransferAction: BidManager.TransferActions {
        switch self {
        case .avoid:
            return .fromAvoidsToLines
        case .bid:
            return .fromBidsToAvoids
        case .neutral:
            return .fromLinesToAvoids
        }
    }
    
}
