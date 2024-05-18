//
//  Bidpack.swift
//  AeroItin
//
//  Created by Matt Zayatz on 8/29/23.
//

import Foundation

struct Bidpack: Equatable, Codable {
    static func == (lhs: Bidpack, rhs: Bidpack) -> Bool {
        lhs.bes == rhs.bes
    }
    
    static let sectionDivider = "#####"
    static let tripDivider = "--------------------------------------------------------------------------------------------"
    static let lineDividerPrefix = "___________________________"
    static let sectionCount = 6
    
    
    static let testOutputFilenameWithExtension = "testOutput.txt"
    static let testOutputUrl = URL.documentsDirectory.appending(path: testOutputFilenameWithExtension)
    
    let base: Base
    let equipment: Equipment
    let month: String
    let year: String
//    let dates: [Date]
    var dates: [BidPeriodDate]
    let trips: [Trip]
    private let captainLines: [Line]
    private let firstOfficerLines: [Line]
    var lines: [Line]
    var bids = [Line]()
    var avoids = [Line]()
        
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
    var seat: Seat {
        didSet {
            resetBid()
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
    
    var linesForCurrentSeat: [Line] {
        seat == .firstOfficer ? firstOfficerLines : captainLines
    }
    
    var lineNumbersOfBids: [String] {
        bids.map { $0.number }
    }
    
    var bes: String {
        base.rawValue + equipment.rawValue + seat.abbreviatedSeat
    }
    
    var besWithBidMonth: String {
        "\(shortMonth) \(year.suffix(2)) (" + bes + ")"
    }
    
    var startDateLocal: Date {
        dates.first?.calendarDate ?? Date(timeIntervalSince1970: .day * 365)
    }
    
    var endDateLocal: Date {
        dates.last?.calendarDate ?? Date(timeIntervalSince1970: .day * 366)
    }
    
    var dateRange: Range<Date> {
        startDateLocal..<endDateLocal.addingTimeInterval(.day)
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
        return monthDictionary[month] ?? ""
    }
    
    
    private var comparator: KeyPathComparator<Line> {
        sortLinesBy.getKeyPath()
    }
    
    init() {
        self.base = .other
        self.equipment = .other
        self.month = "May"
        self.year = "1971"
        self.dates = []
        self.trips = []
        self.captainLines = []
        self.firstOfficerLines = []
        self.lines = []
        self.bids = []
        self.avoids = []
        self.sortLinesBy = .number
        self.sortDescending = false
        self.seat = .firstOfficer
        self.categoryFilter = []
        self.showReserveLines = true
        self.showSecondaryLines = true
        self.showRegularLines = true
    }
    
    init(text: String, seat: Seat) async throws {
        let textRows = text.components(separatedBy: .newlines)
        
        guard let tripsSectionHeader = textRows.first?.split(separator: " ").map(String.init),
              tripsSectionHeader.count >= 8
        else {
            throw ParserError.tripsSectionHeaderNotFound
        }
        
        month = tripsSectionHeader[4]
        year = tripsSectionHeader[5]
        equipment = .from(tripsSectionHeader[2])
        base = .from(tripsSectionHeader[6])
        
        let endIndicies = try Bidpack.findSectionEndIndicies(textRows, sectionCount: Bidpack.sectionCount)
        guard let trips = try Bidpack.findAllTripsIn(textRows, tripsStartIndex: 0, tripsEndIndex: endIndicies.trips, bidMonth: month, bidYear: year) else {
            throw ParserError.noTripsFoundError
        }
        
        self.trips = trips
        
        let lineSectionHeader = try Bidpack.findFirstLineSectionHeaderIn(textRows[endIndicies.trips..<endIndicies.captainRegularLines], fromOffset: 0, timeZone: base.timeZone)
        
        var datesBuffer = [BidPeriodDate]()
        let baseCalendar = Calendar.localCalendarFor(timeZone: base.timeZone)
        for date in lineSectionHeader.dates {
            let isWeekend = baseCalendar.isDateInWeekend(date)
            datesBuffer.append(BidPeriodDate(calendarDate: date, isWeekend: isWeekend))
        }
        
        dates = datesBuffer
        
        var captainLines = try Bidpack.findAllLinesIn(textRows, linesStartIndex: endIndicies.trips, linesEndIndex: endIndicies.captainRegularLines, startDateLocal: dates.first!.calendarDate, timeZone: base.timeZone, trips: trips)
       
        let captainRlg = (captainLines.reduce(0.0) {
            $0 + $1.summary.creditHours
        } / Double(captainLines.count)) * 0.96
        
        var firstOfficerLines = try Bidpack.findAllLinesIn(textRows, linesStartIndex: endIndicies.captainRegularLines, linesEndIndex: endIndicies.firstOfficerRegularLines, startDateLocal: dates.first!.calendarDate, timeZone: base.timeZone, trips: trips)
        
        let firstOfficerRlg = (firstOfficerLines.reduce(0.0) {
            $0 + $1.summary.creditHours
        } / Double(firstOfficerLines.count)) * 0.96
        
        let secondaryLines = Bidpack.computeAllSecondaryLinesIn(textRows, startIndex: endIndicies.firstOfficerReserveLines, endIndex: endIndicies.captainAndFirstOfficerVtoLines)
        
        let captainReserveLines = try Bidpack.findAllReserveLinesIn(textRows, startIndex: endIndicies.firstOfficerRegularLines + 7, endIndex: endIndicies.captainReserveLines - 2, startDateLocal: dates.first!.calendarDate, timeZone: base.timeZone, creditHours: captainRlg)
        
        let firstOfficerReserveLines = try Bidpack.findAllReserveLinesIn(textRows, startIndex: endIndicies.captainReserveLines + 7, endIndex: endIndicies.firstOfficerReserveLines - 2, startDateLocal: dates.first!.calendarDate, timeZone: base.timeZone, creditHours: firstOfficerRlg)
        captainLines.append(contentsOf: captainReserveLines)
        firstOfficerLines.append(contentsOf: firstOfficerReserveLines)
        captainLines.append(contentsOf: secondaryLines.captain)
        firstOfficerLines.append(contentsOf: secondaryLines.firstOfficer)
        
        self.captainLines = captainLines
        self.firstOfficerLines = firstOfficerLines
        
        self.seat = seat
        lines = seat == .firstOfficer ? firstOfficerLines : captainLines
    }
    
    static private func stringToThreeCharacterChunks(_ string: String) -> [String] {
        var chunks = [String]()
        var chunk = ""
        for character in string {
            chunk.append(character)
            if chunk.count == 3 {
                chunks.append(chunk)
                chunk = ""
            }
        }
        if chunk.count > 0 {
            chunks.append(chunk)
        }
        return chunks
    }
    
    static private func findAllReserveLinesIn(
        _ textRows: [String],
        startIndex: Int,
        endIndex: Int,
        startDateLocal: Date,
        timeZone: TimeZone,
        creditHours: TimeInterval) throws -> [Line]
    {
        let rows = textRows[startIndex...endIndex]
        var lines = [Line]()
        let calendarLocal = Calendar.localCalendarFor(timeZone: timeZone)
        for row in rows {
            guard let lineNumber = row.split(separator: "|").first?.trimmingCharacters(in: .whitespaces) else {
                throw ParserError.reserveLineNumberNotFoundError("Near lines \(startIndex) - \(endIndex)")
            }
            
            if lineNumber.isInt {
                let days = Bidpack.stringToThreeCharacterChunks(row.split(separator: "|").dropFirst().joined(separator: "|"))
                let trips = days.enumerated().compactMap { i, text in
                    var trip: Trip? = nil
                    if text.contains("R") || text.contains("A") || text.contains("B") {
                        if let effectiveDate = calendarLocal.date(byAdding: .day, value: i, to: startDateLocal)  {
                            trip = Trip(number: text.trimmingCharacters(in: .whitespaces.union(.symbols)), effectiveDate: effectiveDate)
                        }
                    }
                    return trip
                }
                lines.append(Line(number: String(lineNumber), trips: trips, creditHours: creditHours))
            } else {
                let lineNumbers = lineNumber.split(separator: "-")
                if lineNumbers.count == 2 {
                    let days = Bidpack.stringToThreeCharacterChunks(row)
                    let trips = days.enumerated().compactMap { i, text in
                        var trip: Trip? = nil
                        if text.contains("R") || text.contains("A") || text.contains("B") {
                            if let effectiveDate = calendarLocal.date(byAdding: .day, value: i, to: startDateLocal)  {
                                trip = Trip(number: text.trimmingCharacters(in: .whitespaces.union(.symbols).union(.decimalDigits)), effectiveDate: effectiveDate)
                            }
                        }
                        return trip
                    }
                    let startNumber = Int(lineNumbers.first!) ?? 0
                    let endNumber = Int(lineNumbers.last!) ?? 0
                    for number in startNumber...endNumber {
                        lines.append(Line(number: String(number), trips: trips, creditHours: creditHours))
                    }
                }
            }
        }
        return lines
    }
    
    static func computeAllSecondaryLinesIn(
        _ textRows: [String],
        startIndex: Int,
        endIndex: Int) -> (captain: [Line], firstOfficer: [Line])
    {
        var captainLines = [Line]()
        var firstOfficerLines = [Line]()
        
        let captainCount = textRows[startIndex + 2].split(separator: " ").last
        if let captainCount {
            for i in 1...(Int(captainCount) ?? 0) {
                captainLines.append(Line(number: "S\(i)"))
            }
        }
        
        let firstOfficerCount = textRows[endIndex - 2].split(separator: " ").last
        if let firstOfficerCount {
            for i in 1...(Int(firstOfficerCount) ?? 0) {
                firstOfficerLines.append(Line(number: "S\(i)"))
            }
        }
        
        return (captainLines, firstOfficerLines)
    }
    
    func timeIntervalFromStart(to date: Date) -> TimeInterval {
        startDateLocal.distance(to: date)
    }
    
    mutating func transferLine(line: Line, action: TransferActions, byAppending: Bool) {
        let keyPaths = action.getKeyPaths()
        guard let i = self[keyPath: keyPaths.source].firstIndex(where: { $0.number == line.number }) else {
            return
        }
        byAppending ? self[keyPath: keyPaths.destination].append(self[keyPath: keyPaths.source].remove(at: i)) :
        self[keyPath: keyPaths.destination].insert(self[keyPath: keyPaths.source].remove(at: i), at: self[keyPath: keyPaths.destination].startIndex)
    }
    
    mutating func transferLine(line: Line, action: TransferActions) {
        let keyPaths = action.getKeyPaths()
        guard let i = self[keyPath: keyPaths.source].firstIndex(where: { $0.number == line.number }) else {
            return
        }
        action != .fromBidsToLines ? self[keyPath: keyPaths.destination].append(self[keyPath: keyPaths.source].remove(at: i)) :
        self[keyPath: keyPaths.destination].insert(self[keyPath: keyPaths.source].remove(at: i), at: self[keyPath: keyPaths.destination].startIndex)
    }
    
    mutating func resetBid() {
        bids.removeAll()
        avoids.removeAll()
        lines = linesForCurrentSeat
        sortLinesBy = .number
    }
    
    mutating func moveLine(from source: IndexSet, toOffset destination: Int) {
        guard destination >= lines.startIndex && destination <= lines.endIndex else {
            return
        }
        lines.move(fromOffsets: source, toOffset: destination)
    }
    
    mutating func sortLines() {
        lines.sort(using: comparator)
        if sortDescending {
            lines.reverse()
        }
    }
    
    static private func findFirstLineSectionHeaderIn<T: RandomAccessCollection>(
        _ textRows: T, 
        fromOffset: Int,
        timeZone: TimeZone) throws -> LineSectionHeader where T.Element == String, T.Index == Int
    {
        let headerRegex = /(?<month>[A-Z]){3} \((?<start_date>\d\d\d\d-\d\d-\d\d) - (?<end_date>\d\d\d\d-\d\d-\d\d)\)/
        guard textRows.startIndex + fromOffset + 10 < textRows.endIndex else {
            throw ParserError.lineSectionHeaderNotFoundWithinFiveLinesOfSectionStart
        }
        
        var header: LineSectionHeader? = nil
        
        for row in textRows.prefix(5) {
            if let matchOutput = String(row).firstMatch(of: headerRegex)?.output {
                let formatter = ISO8601DateFormatter.localTimeFormatter(with: timeZone)
                let month = String(matchOutput.month)
                guard let startDate = formatter.date(from: String(matchOutput.start_date)),
                      let endDate = formatter.date(from: String(matchOutput.end_date)) else {
                    throw ParserError.lineSectionHeaderDateParsingError
                }
                
                let calendar = Calendar.localCalendarFor(timeZone: timeZone)
                guard let dates = try? calendar.allDatesBetween(from: startDate, to: endDate, startingOffset: 0, additionalDays: 7),
                      !dates.isEmpty
                else {
                    throw ParserError.lineSectionHeaderDateParsingError
                }
                header = LineSectionHeader(startDate: startDate, endDate: endDate, month: month, dates: dates)
                break
            }
        }
        guard header != nil else {
            throw ParserError.lineSectionHeaderDateParsingError
        }
        return header!
    }
    
    static private func findAllLinesIn(
        _ textRows: [String],
        linesStartIndex: Int,
        linesEndIndex: Int,
        startDateLocal: Date,
        timeZone: TimeZone,
        trips: [Trip]) throws -> [Line]
    {
        var lines = [Line]()
        
        var searchStartIndex = try findFirstLineStartIndexIn(textRows[linesStartIndex..<linesEndIndex])
        
        var maxLoopIterations = 50000
        while searchStartIndex < linesEndIndex {
            guard maxLoopIterations > 0 else {
                throw ParserError.maxLoopIterationsReachedInLineRowsParser
            }
            if let startIndex = try? findFirstLineStartIndexIn(textRows[searchStartIndex..<linesEndIndex]),
               let endIndex = try? findFirstLineEndIndexIn(textRows[startIndex..<linesEndIndex]) {
                if let line = Line(textRows: textRows[startIndex..<endIndex], startDateLocal: startDateLocal, timeZone: timeZone, allTrips: trips) {
                    lines.append(line)
                } else {
                    throw ParserError.lineCouldNotBeCreatedError("Near lines \(startIndex) - \(endIndex)")
                }
                searchStartIndex = endIndex + 1
            } else {
                searchStartIndex += 1
            }
            maxLoopIterations -= 1
        }
        return lines
    }
    
    
    static private func findAllTripsIn(
        _ textRows: [String],
        tripsStartIndex: Int?,
        tripsEndIndex: Int,
        bidMonth: String,
        bidYear: String) throws -> [Trip]?
    {
        var trips = [Trip]()
        var startIndex = tripsStartIndex ?? 0
        var maxLoopIterations = 50000
        while startIndex < tripsEndIndex {
            guard maxLoopIterations > 0 else {
                throw ParserError.maxLoopIterationsReachedInTripRowsParser
            }
            
            if let endIndex = try? findFirstTripEndIndexIn(textRows[startIndex...]) {
                let trimmedTextRows = textRows[startIndex..<endIndex].drop {
                    $0.hasPrefix(" Report for") || $0.isEmpty
                }
                if let trip = Trip(textRows: trimmedTextRows, bidMonth: bidMonth, bidYear: bidYear) {
                    trips.append(trip)
                } else {
                    throw ParserError.tripCouldNotBeCreatedError("Near lines \(startIndex) - \(endIndex)")
                }
                startIndex = endIndex + 1
            } else {
                startIndex += 1
            }
            maxLoopIterations -= 1
        }
        return trips.isEmpty ? nil : trips
    }
    
    static private func findFirstLineEndIndexIn(_ textRows: ArraySlice<String>) throws -> Int {
        try Bidpack.findIndexOf("___________________________", in: textRows, fromOffset: 0)
    }
    
    static private func findFirstLineStartIndexIn(_ textRows: ArraySlice<String>) throws -> Int {
        try Bidpack.findIndexOf("LINE", in: textRows, fromOffset: 0)
    }
    
    static private func findFirstTripEndIndexIn(_ textRows: ArraySlice<String>) throws -> Int {
        try Bidpack.findIndexOf(Bidpack.tripDivider, in: textRows, fromOffset: 0)
    }
    
    static private func findIndexOf<T: RandomAccessCollection>(
        _ string: String, in textRows: T, fromOffset: Int) throws -> Int where T.Element == String, T.Index == Int {
            guard let index = textRows[(textRows.startIndex + fromOffset)...].firstIndex(where: {
                $0.starts(with: string)
            }) else {
                throw ParserError.tokenNotFoundError("Near line \(textRows.startIndex)")
            }
            return index
        }
    
    static private func findSectionEndIndicies(
        _ textRows: [String],
        sectionCount: Int) throws -> EndIndicies
    {
        var indicies = [Int]()
        var lastIndex = -1
        for _ in 0..<sectionCount {
            let index = try findIndexOf(Bidpack.sectionDivider, in: textRows, fromOffset: lastIndex + 1)
            indicies.append(index)
            lastIndex = index
        }
        
        return EndIndicies(
            trips: indicies[0],
            captainRegularLines: indicies[1],
            firstOfficerRegularLines: indicies[2],
            captainReserveLines: indicies[3],
            firstOfficerReserveLines: indicies[4],
            captainAndFirstOfficerVtoLines: indicies[5]
        )
    }
    
    struct EndIndicies {
        let trips: Int
        let captainRegularLines: Int
        let firstOfficerRegularLines: Int
        let captainReserveLines: Int
        let firstOfficerReserveLines: Int
        let captainAndFirstOfficerVtoLines: Int
    }
    
    struct LineSectionHeader {
        let startDate: Date
        let endDate: Date
        let month: String
        let dates: [Date]
    }
    
    enum Seat: String, Codable  {
        case captain = "Captain"
        case firstOfficer = "First Officer"
        
        var abbreviatedSeat: String {
            switch self {
            case .captain:
                return "C"
            case .firstOfficer:
                return "F"
            }
        }
    }
    
    
    
    enum Base: String, Codable {
        case mem = "MEM"
        case ind = "IND"
        case lax = "LAX"
        case oak = "OAK"
        case anc = "ANC"
        case eur = "EUR"
        case other
        
        var timeZone: TimeZone {
            switch self {
            case .mem:
                return TimeZone.mem
            case .ind:
                return TimeZone.ind
            case .lax:
                return TimeZone.lax
            case .oak:
                return TimeZone.oak
            case .anc:
                return TimeZone.anc
            case .eur:
                return TimeZone.eur
            case .other:
                return TimeZone.gmt
            }
        }
        
        static func from(_ string: String) -> Base {
            switch string {
            case "MEM":
                return .mem
            case "IND":
                return .ind
            case "LAX":
                return .lax
            case "OAK":
                return .oak
            case "ANC":
                return .anc
            case "EUR":
                return .eur
            default:
                return .other
            }
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
            }
        }
    }
    
    enum Equipment: String, Codable {
        case md11 = "11"
        case a300 = "30"
        case b757 = "57"
        case b767 = "67"
        case b777 = "77"
        case other
        
        static func from(_ string: String) -> Equipment {
            switch string {
            case "MD11":
                return .md11
            case "A300":
                return .a300
            case "B757":
                return .b757
            case "B767":
                return .b767
            case "B777":
                return .b777
            default:
                return .other
            }
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
    
    var plusTransferAction: Bidpack.TransferActions {
        switch self {
        case .avoid:
            return .fromAvoidsToBids
        case .bid:
            return .fromBidsToLines
        case .neutral:
            return .fromLinesToBids
        }
    }
    
    var minusTransferAction: Bidpack.TransferActions {
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
