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
    
    init() throws {
        let text = try String(contentsOf: Bidpack.testBidpackUrl)
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
                }
                startIndex = endIndex + 1
            } else {
                startIndex += 1
            }
            maxLoopIterations -= 1
        }
        return trips.isEmpty ? nil : trips
    }
    
    static private func findFirstTripEndIndexIn(_ textRows: ArraySlice<String>) throws -> Int {
        try Bidpack.findIndexOf(Bidpack.tripDivider, in: textRows, fromOffset: 0)
    }
    
    static private func findIndexOf<T: RandomAccessCollection>(_ string: String, in textRows: T,
                                                       fromOffset: Int) throws -> Int where T.Element == String, T.Index == Int {
        guard let index = textRows[(textRows.startIndex + fromOffset)...].firstIndex(where: {
            $0.starts(with: string)
        }) else {
            throw ParserError.tokenNotFoundError
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
    
    enum Base: String {
        case MEM
        case IND
        case LAX
        case OAK
        case ANC
        case EUR
        case other
        
        static func from(_ string: String) -> Base {
            switch string {
            case "MEM":
                return .MEM
            case "IND":
                return .IND
            case "LAX":
                 return .LAX
            case "OAK":
                return .OAK
            case "ANC":
                return .ANC
            case "EUR":
                return .EUR
            default:
                return .other
            }
        }
    }
    
    enum Equipment: String {
        case MD11
        case A300
        case B757
        case B767
        case B777
        case other
        
        static func from(_ string: String) -> Equipment {
            switch string {
            case "MD11":
                return .MD11
            case "A300":
                return .A300
            case "B757":
                 return .B757
            case "B767":
                return .B767
            case "B777":
                return .B777
            default:
                return .other
            }
        }
    }
}

