//
//  Bidpack.swift
//  AeroItin
//
//  Created by Matt Zayatz on 8/29/23.
//

import Foundation

struct Bidpack {
    static let sectionDivider = "#####"
    static let tripDivider = "--------------------------------------------------------------------------------------------"
    static let lineDividerPrefix = "___________________________"
    static let sectionCount = 6
    
    static let testBidpackFilename = "2023_Sep_MD11_MEM_LINES"
    static let testBidpackExtension = "asc"
    static let testBidpackUrl =
    Bundle.main.url(forResource: Bidpack.testBidpackFilename, withExtension: Bidpack.testBidpackExtension)!
    
    static let testOutputFilenameWithExtension = "testOutput.txt"
    static let testOutputUrl = URL.documentsDirectory.appending(path: testOutputFilenameWithExtension)
    let textRows: [String]
    let base: Base
    let equipment: Equipment
    let month: String
    let year: String
    let dates: [Date]
    let trips: [Trip]
    private(set) var sortLinesBy: SortOptions = .number
    private(set) var seat: Seat
    private var captainLines: [Line]
    private var firstOfficerLines: [Line]
    
    var startDateLocal: Date {
        dates.first!
    }
    
    var endDateLocal: Date {
        dates.last!
    }
    
    var datesAsDayOfMonthStrings: [String] {
        let formatter = DateFormatter.localDayOfMonthFormatterIn(base.timeZone)
        return dates.map { formatter.string(from: $0) }
    }
    
    private(set) var lines: [Line] {
        get {
            switch seat {
            case .captain:
                return captainLines
            case .firstOfficer:
                return firstOfficerLines
            }
        }
        
        set {
            switch seat {
            case .captain:
                captainLines = newValue
            case .firstOfficer:
                firstOfficerLines = newValue
            }
        }
    }
    
    private var comparator: KeyPathComparator<Line> {
        sortLinesBy.getKeyPath()
    }
    
    init() throws {
        try self.init(with: Bidpack.testBidpackUrl, seat: .firstOfficer)
    }
    
    init(with url: URL, seat: Seat) throws {
        let text = try String(contentsOf: url)
        textRows = text.components(separatedBy: .newlines)
        
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
        
        dates = lineSectionHeader.dates
        
        guard let captainLines = try Bidpack.findAllLinesIn(textRows, linesStartIndex: endIndicies.trips, linesEndIndex: endIndicies.captainRegularLines, startDateLocal: dates.first!, timeZone: base.timeZone, trips: trips),
              let firstOfficerLines = try Bidpack.findAllLinesIn(textRows, linesStartIndex: endIndicies.captainRegularLines, linesEndIndex: endIndicies.firstOfficerRegularLines, startDateLocal: dates.first!, timeZone: base.timeZone, trips: trips) else {
            throw ParserError.noLinesFoundError
        }
        self.captainLines = captainLines
        self.firstOfficerLines = firstOfficerLines
        self.seat = seat
        print(startDateLocal)
    }
    
    func timeIntervalFromStart(to date: Date) -> TimeInterval {
        startDateLocal.distance(to: date)
    }
    
    mutating func setFlag(for line: Line, flag: Line.Flag) {
        guard let i = lines.firstIndex(where: { $0.number == line.number }) else {
            return
        }
        lines[i].flag = flag
        lines = lines.filter { $0.flag == .bid } + lines.filter { $0.flag == .neutral } + lines.filter{ $0.flag == .avoid }
    }
    
    mutating func setSeat(to seat: Seat)  {
        self.resetBid()
        self.seat = seat
    }
    
    mutating func setSort(to sortOption: SortOptions) {
        sortLinesBy = sortOption
        sortNeturalLines()
    }
    
    mutating func resetBid() {
        for i in lines.indices {
            lines[i].resetFlag()
        } 
        sortLines()
    }
    
    mutating func resetBidButKeepAvoids() {
        for i in lines.indices {
            if lines[i].flag == .bid {
                lines[i].resetFlag()
            }
        }
    }
    
    mutating func moveLine(from source: IndexSet, toOffset destination: Int) {
        guard destination >= lines.startIndex && destination <= lines.endIndex else {
            return
        }
        lines.move(fromOffsets: source, toOffset: destination)
        lines = lines.filter { $0.flag == .bid } + lines.filter { $0.flag == .neutral } + lines.filter{ $0.flag == .avoid }
    }
    
    mutating func sortLines() {
        lines.sort(using: comparator)
    }
    
    mutating func sortNeturalLines() {
        lines = lines.filter { $0.flag == .bid } + lines.filter { $0.flag == .neutral }.sorted(using: comparator) + lines.filter{ $0.flag == .avoid }
    }
    
    static private func findFirstLineSectionHeaderIn<T: RandomAccessCollection>(
        _ textRows: T, fromOffset: Int, timeZone: TimeZone) throws -> LineSectionHeader where T.Element == String, T.Index == Int
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
    
    static private func findAllLinesIn(_ textRows: [String], linesStartIndex: Int, linesEndIndex: Int, startDateLocal: Date, timeZone: TimeZone, trips: [Trip]) throws -> [Line]? {
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
        return lines.isEmpty ? nil : lines
    }
    
    
    static private func findAllTripsIn(_ textRows: [String], tripsStartIndex: Int?, tripsEndIndex: Int, bidMonth: String, bidYear: String) throws -> [Trip]? {
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
    
    static private func findSectionEndIndicies(_ textRows: [String], sectionCount: Int) throws -> EndIndicies {
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
    
    enum Seat {
        case captain
        case firstOfficer
    }
    
    enum Base: String {
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
    
    enum SortOptions: String, CaseIterable {
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
    }
    
    enum Equipment: String {
        case md11 = "MD11"
        case a300 = "A300"
        case b757 = "B757"
        case b767 = "B767"
        case b777 = "B777"
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

