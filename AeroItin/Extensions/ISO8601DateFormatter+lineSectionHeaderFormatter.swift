//
//  ISO8601DateFormatter+lineSectionHeaderFormatter.swift
//  AeroItin
//
//  Created by Matt Zayatz on 8/31/23.
//

import Foundation

extension ISO8601DateFormatter {
    static var lineSectionHeaderFormatter: ISO8601DateFormatter {
        let df = ISO8601DateFormatter()
        df.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        return df
    }
    
    static func localTimeFormatter(with timeZone: TimeZone) -> ISO8601DateFormatter {
        let df = ISO8601DateFormatter()
        df.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        df.timeZone = timeZone
        return df
    }
}
