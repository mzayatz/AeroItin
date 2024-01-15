//
//  DateFormatter+formatterForTripHeader.swift
//  AeroItin
//
//  Created by Matt Zayatz on 8/30/23.
//

import Foundation

extension DateFormatter {
    private static var localDayOfMonthFormatters: [TimeZone: DateFormatter] = [:]
    
    static let tripHeaderFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy MMM dd HH:mm"
        df.timeZone = .gmt
        return df
    }()
    
    static let tripDayFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "EEEEEE"
        df.timeZone = .gmt
        return df
    }()
    
    static let timeStampFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyMMdd-HHmm'Z'"
        df.timeZone = .gmt // GMT
        return df
    }()
    
    static var fileTimeStamp: String {
        timeStampFormatter.string(from: Date.now)
    }

    static func localDayOfMonthFormatterIn(_ timeZone: TimeZone) -> DateFormatter {
        if let formatter = localDayOfMonthFormatters[timeZone] {
            return formatter
        } else {
            let df = DateFormatter()
            df.dateFormat = "dd"
            df.timeZone = timeZone
            localDayOfMonthFormatters[timeZone] = df
            return df
        }
    }
    
    static func dayStringFor(date: Date, in timeZone: TimeZone) -> String {
        let formatter = localDayOfMonthFormatterIn(timeZone)
        return formatter.string(from: date)
    }
}
