//
//  Calendar+zulu.swift
//  AeroItin
//
//  Created by Matt Zayatz on 8/30/23.
//

import Foundation

extension Calendar {
    static var zulu: Calendar {
        var calendar = Calendar.init(identifier: .iso8601)
        calendar.timeZone = .gmt
        return calendar
    }
    
    static func localCalendarFor(timeZone: TimeZone) -> Calendar {
        var calendar = Calendar.init(identifier: .iso8601)
        calendar.timeZone = timeZone
        return calendar
    }
    
    func allDatesBetween(from startingDate: Date, to endingDate: Date) throws -> [Date] {
        guard startingDate < endingDate else {
            throw DateError.endDateOccursBeforeStartDate("starting date: \(startingDate) > \(endingDate)")
        }
        var offset = 1
        var lastDate = startingDate
        var allDates = [Date]()
        repeat {
            lastDate = self.date(byAdding: .day, value: offset, to: startingDate)!
            allDates.append(lastDate)
            offset += 1
        } while(lastDate < endingDate)
        return allDates
    }
}
