//
//  ISO8601DateFormatter+localTimeFormatter.swift
//  AeroItin
//
//  Created by Matt Zayatz on 8/31/23.
//

import Foundation

extension ISO8601DateFormatter {
    static func localTimeFormatter(with timeZone: TimeZone, withTime: Bool = false) -> ISO8601DateFormatter {
        let df = ISO8601DateFormatter()
        df.formatOptions = withTime ? [.withFullDate, .withDashSeparatorInDate, .withFullTime, .withTimeZone] : [.withFullDate, .withDashSeparatorInDate]
        df.timeZone = timeZone
        return df
    }
}
