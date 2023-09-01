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
    let startDateLocal: Date
    let endDateLocal: Date
    let trips: [Trip]
    
    init() throws {
        try self.init(with: Bidpack.testBidpackUrl)
    }
    
    init(with url: URL) throws {
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
        
        startDateLocal = lineSectionHeader.startDate
        endDateLocal = lineSectionHeader.endDate
        
        let captainLines = try Bidpack.findAllLinesIn(textRows, linesStartIndex: endIndicies.trips, linesEndIndex: endIndicies.captainRegularLines, startDateLocal: startDateLocal, timeZone: base.timeZone, trips: trips)!
        
        let firstOfficerLines = try Bidpack.findAllLinesIn(textRows, linesStartIndex: endIndicies.captainRegularLines, linesEndIndex: endIndicies.firstOfficerRegularLines, startDateLocal: startDateLocal, timeZone: base.timeZone, trips: trips)!
        
//        print(captainLines.first { $0.number == "1022" }!.trips)
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
                header = LineSectionHeader(startDate: startDate, endDate: endDate, month: month)
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

