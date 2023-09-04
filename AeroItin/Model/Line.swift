//
//  Line.swift
//  AeroItin
//
//  Created by Matt Zayatz on 8/31/23.
//

import Foundation

struct Line: CustomStringConvertible, Identifiable {
    let textRows: ArraySlice<String>
    let number: String
    let trips: [Trip]
    var flag: Flag
    var id: String
    let summary: Summary
    
    init?(textRows: ArraySlice<String>, startDateLocal: Date, timeZone: TimeZone, allTrips: [Trip]) {
        guard textRows.count == 6 else {
            assertionFailure("Line textRows != 6. Should be 6.")
            return nil
        }
        self.textRows = textRows
        guard let lineNumberSplit = textRows.first?.split(separator: "|").first?.split(separator: " "),
              lineNumberSplit.count > 1
        else {
            assertionFailure("Problem reading line number")
            return nil
        }
        number = String(lineNumberSplit[1])
        guard let summary = Summary(textRows: textRows) else {
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
                var trip = Line.matchTrip(tripList: tripList, tripNumber: tripNumber, dayIndex: i, calendarLocal: calendarLocal, startDateLocal: startDateLocal)
                
                if trip == nil {
                    trip = Line.matchTrip(tripList: tripList, tripNumber: tripNumber, dayIndex: i+1, calendarLocal: calendarLocal, startDateLocal: startDateLocal)
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
        flag = .neutral
        id = number
    }
    
    mutating func resetFlag() {
        self.flag = .neutral
    }
    
    static func matchTrip(tripList: [Trip], tripNumber: String, dayIndex: Int, calendarLocal: Calendar, startDateLocal: Date) -> Trip? {
        guard let date = calendarLocal.date(byAdding: .day, value: dayIndex, to: startDateLocal) else {
            assertionFailure("Could not calculate date from lineTripsRow...")
            return nil
        }
        
        let trips = tripList.filter {
            for effectiveDate in $0.effectiveDates {
                if(calendarLocal.compare(date, to: effectiveDate, toGranularity: .day) == .orderedSame) {
                    return true
                }
            }
            return false
        }
        
        guard trips.count == 1 else {
            return nil
        }
        
        return trips.first!
    }
    
    var description: String {
        "\(number)"
    }
    
    struct Summary {
        let creditHours: TimeInterval
        let timeAwayFromBase: TimeInterval
        let carryOutCreditHours: TimeInterval
        let dutyPeriods: Int
        let blockHours: TimeInterval
        let landings: Int
        let carryOutBlockHours: TimeInterval
        let daysOff: Int
        
        init?(textRows: ArraySlice<String>) {
            guard let creditHoursAndtimeAwayFromBase = Summary.findLineSummaryDataIn(textRows[textRows.startIndex + 2]),
                  let carryOutCreditHoursAndDutyPeriods = Summary.findLineSummaryDataIn(textRows[textRows.startIndex + 3]),
                  let blockHoursAndLandings = Summary.findLineSummaryDataIn(textRows[textRows.startIndex + 4]),
                  let carryOutBlockHoursAndDaysOff = Summary.findLineSummaryDataIn(textRows[textRows.startIndex + 5]) else {
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
    
    enum Flag: String {
        case neutral = "Neutral"
        case avoid = "Avoid"
        case bid = "Bid"
    }
}
