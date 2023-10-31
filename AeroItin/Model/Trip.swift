//
//  Trip.swift
//  AeroItin
//
//  Created by Matt Zayatz on 8/29/23.
//

import Foundation

struct Trip: CustomStringConvertible, Equatable, Codable {
    let text: [String]
    let number: String
    let effectiveDates: [Date]
    let creditHours: TimeInterval
    let blockHours: TimeInterval
    let landings: Int
    let timeAwayFromBase: TimeInterval
    let layovers: [String]
    let deadheads: Deadheads
    
    static let dayAbbreviations = ["EXCEPT", "MO", "TU", "WE", "TH", "FR", "SA", "SU"]
    
    var firstEffectiveDate: Date {
        return effectiveDates.first!
    }
    
    var shortDescription: String {
        layovers.joined(separator: "-")
    }
    
    init(trip: Trip, effectiveDate: Date) {
        text = trip.text
        number = trip.number
        effectiveDates = [effectiveDate]
        creditHours = trip.creditHours
        blockHours = trip.blockHours
        landings = trip.landings
        timeAwayFromBase = trip.timeAwayFromBase
        layovers = trip.layovers
        deadheads = trip.deadheads
    }
    
    init?(textRows: ArraySlice<String>, bidMonth: String, bidYear: String) {
        self.text = Array(textRows)
        guard var firstRowWords = self.text.first?.split(separator: " ").map(String.init),
              !firstRowWords.isEmpty
        else {
            assertionFailure("Problem reading first row of trip (Trip.swift)")
            return nil
        }
        number = firstRowWords.removeFirst()
        
        var daysOfWeek = [String]()
        
        var foundLastDay = false
        var maxLoopIterations = firstRowWords.count
        repeat {
            guard !firstRowWords.isEmpty && maxLoopIterations > 0 else {
                assertionFailure("Never exited daysOfWeek Loop (Trip.swift)")
                return nil
            }
            if Trip.dayAbbreviations.contains(firstRowWords.first!) {
                daysOfWeek.append(firstRowWords.removeFirst())
            } else {
                foundLastDay = true
            }
            maxLoopIterations -= 1
        } while !foundLastDay
        if daysOfWeek.first! == "EXCEPT" {
            daysOfWeek = Array(Set(Trip.dayAbbreviations).subtracting(daysOfWeek))
        }
        
        guard firstRowWords.count == 9 && firstRowWords.startIndex == 0 else {
            assertionFailure("Remaining words in trip header != 9 or startIndex != 0 (Trip.swift)")
            return nil
        }
        effectiveDates = Trip.computeValidDatesFrom(firstRowWords, bidMonth: bidMonth, bidYear: bidYear)!.filter {
            daysOfWeek.contains(DateFormatter.tripDayFormatter.string(from: $0).uppercased())
        }
        
        guard let lastRowWords = textRows.last?.split(separator: " ").map(String.init),
              lastRowWords.count == 10
        else {
            assertionFailure("Problem reading last row of trip (Trip.swift)")
            return nil
        }
        guard let creditHours = TimeInterval(fromTimeString: lastRowWords[2]),
              let blockHours = TimeInterval(fromTimeString: lastRowWords[5]),
              let landings = Int(lastRowWords[7]),
              let timeAwayFromBase = TimeInterval(fromTimeString: lastRowWords[9]) else {
            assertionFailure("Problem parsing last row of trip (Trip.swift)")
            return nil
        }
        self.creditHours = creditHours
        self.blockHours = blockHours
        self.landings = landings
        self.timeAwayFromBase = timeAwayFromBase
        
        self.layovers = Trip.findLayovers(in: textRows)
        self.deadheads = Trip.findDeadheads(in: textRows)
    }
    
    static private func findDeadheads(in rows: ArraySlice<String>) -> Deadheads {
        let isFrontDeadhead = rows[rows.startIndex + 3].split(separator: " ")[1].isDeadheadFlightCode
        let isBackDeadhead = rows[rows.endIndex - 3].split(separator: " ")[1].isDeadheadFlightCode
        
        if isFrontDeadhead && isBackDeadhead {
            return .double
        } else if isFrontDeadhead {
            return .front
        } else if isBackDeadhead {
            return .back
        } else {
            return .none
        }
    }
    
    static private func findLayovers(in rows: ArraySlice<String>) -> [String] {
        var layovers = [String]()
        let regex = /(?P<iata>[A-Z]{3}) (?P<duration>\d\d:\d\d)/
        for layover in rows.joined().matches(of: regex) {
            layovers.append(String(layover.output.iata).lowercased())
        }
        return layovers
    }
    
    static private func computeValidDatesFrom(_ firstRowWords: [String], bidMonth: String, bidYear: String) -> [Date]? {
        let zuluStartTimeString = firstRowWords[2]
        let zuluStartingMonthString = firstRowWords[6]
        var zuluStartingDayWithMaybeEndingMonth = firstRowWords[7].components(separatedBy: "-")
        let zuluStartingDayString = zuluStartingDayWithMaybeEndingMonth.removeFirst()
        let zuluEndingMonthString = zuluStartingDayWithMaybeEndingMonth.last
        let zuluEndingDayString = firstRowWords[8] == "ONLY" ? nil : firstRowWords[8]
        guard (zuluEndingDayString == nil && zuluEndingMonthString == nil) ||
                (zuluEndingDayString != nil && zuluEndingMonthString != nil) else {
            assertionFailure("Problem parsing effective dates (Trip.swift)")
            return nil
        }
        
        guard let zuluStartingYearString = computeYear(bidMonth: bidMonth, bidYear: bidYear, tripMonth: zuluStartingMonthString) else {
            assertionFailure("computeYear function could not compute the trip start/end year")
            return nil
        }
        
        var validDates = [Date]()
        
        guard let startingDate = DateFormatter.tripHeaderFormatter.date(from:([zuluStartingYearString, zuluStartingMonthString, zuluStartingDayString, zuluStartTimeString].joined(separator: " "))) else {
            assertionFailure("Problem creating date from starting effective date components")
            return nil
        }
        validDates.append(startingDate)
        
        if zuluEndingMonthString != nil {
            guard let zuluEndingYearString = computeYear(bidMonth: bidMonth, bidYear: bidYear, tripMonth: zuluEndingMonthString!) else {
                assertionFailure("computeYear function could not compute the trip start/end year")
                return nil
            }
            
            guard let endingDate = DateFormatter.tripHeaderFormatter.date(from:([zuluEndingYearString, zuluEndingMonthString!, zuluEndingDayString!, zuluStartTimeString].joined(separator: " "))) else {
                assertionFailure("Problem creating date from ending effective date components")
                return nil
            }
            guard startingDate < endingDate else {
                assertionFailure("starting effective date isn't less than ending effective date")
                return nil
            }
            guard let moreValidDates = try? Calendar.zulu.allDatesBetween(from: startingDate, to: endingDate) else {
                assertionFailure("a valid date was not properly computed in computeValidDatesFrom (Trip.swift).")
                return nil
            }
            validDates.append(contentsOf: moreValidDates)
        }
        
        return validDates
    }
    
    static private func computeYear(bidMonth: String, bidYear: String, tripMonth: String) -> String? {
        if bidMonth != "DECEMBER" && bidMonth != "JANUARY" {
            return bidYear
        }
        
        guard let intYear = Int(bidYear) else {
            assertionFailure("Could not convert string to integer in Trip.computeYear")
            return nil
        }
        
        if bidMonth == "DECEMBER" && tripMonth == "JAN" {
            return String(intYear + 1)
        }
        
        if bidMonth == "JANUARY" && tripMonth == "DEC" {
            return String(intYear - 1)
        }
        assertionFailure("computeYear function could not compute the trip start/end year")
        return nil
    }
    var description: String {
        "\(number)"
    }
    
    enum Deadheads: Codable {
        case double
        case front
        case back
        case none
    }
}
