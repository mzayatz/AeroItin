//
//  Line.swift
//  AeroItin
//
//  Created by Matt Zayatz on 8/31/23.
//

import Foundation

struct Line: CustomStringConvertible, Identifiable, Equatable, Codable {
    let text: [String]
    let number: String
    let trips: [Trip]
    let summary: Summary
    let layovers: Set<String>
    let category: Line.Category
    let hasDeadhead: Bool
    var pilot: Pilot? = nil
    var userAward = false
    
    let id: UUID
    
    init(number: String) {
        self.number = number
        text = [String]()
        trips = [Trip]()
        summary = Summary()
        layovers = Set<String>()
        category = .secondary
        hasDeadhead = false
        id = UUID()
    }
    
    init(number: String, trips: [Trip], creditHours: TimeInterval = 0) {
        self.number = number
        text = [String]()
        self.trips = trips
        summary = Summary(creditHours: creditHours)
        layovers = Set<String>()
        category = .reserve
        hasDeadhead = false
        id = UUID()
    }
    
    init?(textRows: ArraySlice<String>, startDateLocal: Date, timeZone: TimeZone, allTrips: [Trip]) {
        guard textRows.count == 6 else {
            assertionFailure("Line text != 6. Should be 6.")
            return nil
        }
        self.text = Array(textRows)
        guard let lineNumberSplit = textRows.first?.split(separator: "|").first?.split(separator: " "),
              lineNumberSplit.count > 1
        else {
            assertionFailure("Problem reading line number")
            return nil
        }
        number = String(lineNumberSplit[1])
        guard let summary = Summary(text: text) else {
            assertionFailure("Problem reading line summary")
            return nil
        }
        self.summary = summary
        
        let lineTripNumbersArray = textRows[textRows.startIndex + 4].split(separator: "|").dropFirst().flatMap {
            $0.split(separator: ":").map{$0.trimmingCharacters(in: .whitespaces)}
        }
        let calendarLocal = Calendar.localCalendarFor(timeZone: timeZone)
        var lineTrips = [Trip]()

        for (i, tripNumber) in lineTripNumbersArray.enumerated() {
            if tripNumber.isInt {
                let tripList = allTrips.filter { $0.number == tripNumber }
                var trip = Line.matchTrip(tripList: tripList, dayIndex: i, calendarLocal: calendarLocal, startDateLocal: startDateLocal)
                
                if trip == nil {
                    trip = Line.matchTrip(tripList: tripList, dayIndex: i, calendarLocal: calendarLocal, startDateLocal: startDateLocal, subtractDayFromEffectiveDates: true)
                }
                
                guard let trip else {
                    assertionFailure("Could not find a trip to match the dates")
                    return nil
                }
                lineTrips.append(trip)
            }
        }
        guard lineTripNumbersArray.filter(\.isInt).count == lineTrips.count else {
            assertionFailure("The line is missing some trips...")
            return nil
        }
        self.trips = lineTrips
        var layoversBuffer = Set<String>()
        var deadheadBuffer = false
        for trip in trips {
            layoversBuffer.formUnion(trip.layovers)
            deadheadBuffer = deadheadBuffer ? deadheadBuffer : trip.deadheads != .none
        }
        layovers = layoversBuffer
        category = .regular
        hasDeadhead = deadheadBuffer
        id = UUID()
    }
    
    static func matchTrip(tripList: [Trip], dayIndex: Int, calendarLocal: Calendar, startDateLocal: Date, subtractDayFromEffectiveDates: Bool = false) -> Trip? {
        guard let date = calendarLocal.date(byAdding: .day, value: dayIndex, to: startDateLocal) else {
            assertionFailure("Could not calculate date from lineTripsRow...")
            return nil
        }
        var originalTripDate: Date? = nil
        let trips = tripList.filter {
            for effectiveDate in $0.effectiveDates {
                let modifiedEffectiveDate = subtractDayFromEffectiveDates ? effectiveDate.addingTimeInterval(-(.day)) : effectiveDate
                let dateComparison = calendarLocal.compare(date, to: modifiedEffectiveDate, toGranularity: .day)
                if(dateComparison == .orderedSame) {
                    originalTripDate = modifiedEffectiveDate
                    return true
                }
            }
            return false
        }
        
        guard trips.count == 1 && originalTripDate != nil else {
            return nil
        }
        return Trip(trip: trips.first!, effectiveDate: originalTripDate!)
    }
    
    var description: String {
        "\(number)"
    }
    
    struct Summary: Equatable, Codable {
        let creditHours: TimeInterval
        let timeAwayFromBase: TimeInterval
        let carryOutCreditHours: TimeInterval
        let dutyPeriods: Int
        let blockHours: TimeInterval
        let landings: Int
        let carryOutBlockHours: TimeInterval
        let daysOff: Int
        
        init() {
            creditHours = 0
            timeAwayFromBase = 0
            carryOutCreditHours = 0
            dutyPeriods = 0
            blockHours = 0
            landings = 0
            carryOutBlockHours = 0
            daysOff = 0
        }
        
        init(creditHours: TimeInterval) {
            self.creditHours = creditHours
            timeAwayFromBase = 0
            carryOutCreditHours = 0
            dutyPeriods = 0
            blockHours = 0
            landings = 0
            carryOutBlockHours = 0
            daysOff = 0
        }
        
        init?(text: [String]) {
            guard let creditHoursAndtimeAwayFromBase = Summary.findLineSummaryDataIn(text[text.startIndex + 2]),
                  let carryOutCreditHoursAndDutyPeriods = Summary.findLineSummaryDataIn(text[text.startIndex + 3]),
                  let blockHoursAndLandings = Summary.findLineSummaryDataIn(text[text.startIndex + 4]),
                  let carryOutBlockHoursAndDaysOff = Summary.findLineSummaryDataIn(text[text.startIndex + 5]) else {
                assertionFailure("Problem reading line summary")
                return nil
            }
            guard let creditHours = TimeInterval(fromTimeString: creditHoursAndtimeAwayFromBase.0),
                  let timeAwayFromBase = TimeInterval(fromTimeString: creditHoursAndtimeAwayFromBase.1),
                  let carryOutCreditHours = TimeInterval(fromTimeString: carryOutCreditHoursAndDutyPeriods.0),
                  let dutyPeriods = Int(carryOutCreditHoursAndDutyPeriods.1),
                  let blockHours = TimeInterval(fromTimeString: blockHoursAndLandings.0),
                  let landings = Int(blockHoursAndLandings.1),
                  let carryOutBlockHours = TimeInterval(fromTimeString: carryOutBlockHoursAndDaysOff.0),
                  let daysOff = Int(carryOutBlockHoursAndDaysOff.1) else {
                assertionFailure("Problem converting line summary from strings to TimeIntervals / Ints")
                return nil
            }
            self.creditHours = creditHours
            self.timeAwayFromBase = timeAwayFromBase
            self.carryOutCreditHours = carryOutCreditHours
            self.dutyPeriods = dutyPeriods
            self.blockHours = blockHours
            self.landings = landings
            self.carryOutBlockHours = carryOutBlockHours
            self.daysOff = daysOff
        }
        
        static private func findLineSummaryDataIn(_ string: String) -> (String, String)? {
            guard let chunk = string.split(separator: "|").first else {
                assertionFailure("Problem reading line summary")
                return nil
            }
            
            let trimmedSplitChunk = chunk.split(separator: " ").dropFirst()
            guard let firstString = trimmedSplitChunk.first,
                  let secondString = trimmedSplitChunk.last else {
                assertionFailure("Problem reading line summary")
                return nil
            }
            return (String(firstString), String(secondString))
        }
        
    }
    
    enum Flag: String, Codable {
        case neutral = "Neutral"
        case avoid = "Avoid"
        case bid = "Bid"
    }
    
    enum Category: Codable {
        case regular
        case reserve
        case secondary
    }
}
