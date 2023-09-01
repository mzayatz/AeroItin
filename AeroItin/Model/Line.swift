//
//  Line.swift
//  AeroItin
//
//  Created by Matt Zayatz on 8/31/23.
//

import Foundation

struct Line {
    let textRows: ArraySlice<String>
    let number: String
    let summary: LineSummary
    
    init?(textRows: ArraySlice<String>, startDateLocal: Date) {
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
        guard let summary = LineSummary(textRows: textRows) else {
            assertionFailure("Problem reading line summary")
            return nil
        }
        self.summary = summary
    }
    
    struct LineSummary: CustomStringConvertible {
        let creditHours: TimeInterval
        let timeAwayFromBase: TimeInterval
        let carryOutCreditHours: TimeInterval
        let dutyPeriods: Int
        let blockHours: TimeInterval
        let landings: Int
        let carryOutBlockHours: TimeInterval
        let daysOff: Int
        
        init?(textRows: ArraySlice<String>) {
            guard let creditHoursAndtimeAwayFromBase = LineSummary.findLineSummaryDataIn(textRows[textRows.startIndex + 2]),
                  let carryOutCreditHoursAndDutyPeriods = LineSummary.findLineSummaryDataIn(textRows[textRows.startIndex + 3]),
                  let blockHoursAndLandings = LineSummary.findLineSummaryDataIn(textRows[textRows.startIndex + 4]),
                  let carryOutBlockHoursAndDaysOff = LineSummary.findLineSummaryDataIn(textRows[textRows.startIndex + 5]) else {
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
        
        
        var description: String {
"""
  Credit: \(creditHours.asHours.formatted(.number.precision(.fractionLength(1))))
    TAFB: \(timeAwayFromBase.asHours.formatted(.number.precision(.fractionLength(1))))
Landings: \(landings)
"""
        }
    }
}
