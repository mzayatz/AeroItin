//
//  Bidpack.swift
//  AeroItin
//
//  Created by Matt Zayatz on 8/29/23.
//

import Foundation

struct Bidpack: Equatable, Codable {
    
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
    var dates: [BidPeriodDate]
    let trips: [Trip]
    private let captainLines: [Line]
    private let firstOfficerLines: [Line]
    var lines: [Line]
    var bids = [Line]()
    var avoids = [Line]()
    
    var pilotsIntegrated = false
    
    var seat: Seat {
        didSet {
            resetBid()
        }
    }
    
    var startDateLocal: Date {
        dates.first?.calendarDate ?? Date(timeIntervalSince1970: .day * 365)
    }
    
    var endDateLocal: Date {
        dates.last?.calendarDate ?? Date(timeIntervalSince1970: .day * 366)
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
        self.seat = .firstOfficer
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

    mutating func resetBid() {
        bids.removeAll()
        avoids.removeAll()
        lines = restoreLines()
    }
    
    mutating func integratePilots(_ pilots: [Pilot], userEmployeeNumber: String) {
        //TODO: Save bid and reload after pilot integration
        resetBid()
        lines.sort(using: BidManager.SortOptions.number.getKeyPath())
        for pilot in pilots {
            if let i = lines.firstIndex(where: { line in
                line.number == pilot.awardedLine
            }) {
                lines[i].pilot = pilot
                if userEmployeeNumber == pilot.employeeNumber {
                    lines[i].userAward = true
                }
            }
        }
        pilotsIntegrated = true
    }
    
    mutating func removePilots() {
        resetBid()
        for i in lines.indices {
            lines[i].pilot = nil
        }
        pilotsIntegrated = false
    }
    
    private mutating func restoreLines() -> [Line] {
        seat == .firstOfficer ? firstOfficerLines : captainLines
    }
    
    mutating func moveLine(from source: IndexSet, toOffset destination: Int) {
        guard destination >= lines.startIndex && destination <= lines.endIndex else {
            return
        }
        lines.move(fromOffsets: source, toOffset: destination)
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

