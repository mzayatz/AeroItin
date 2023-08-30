//
//  DateFormatter+formatterForTripHeader.swift
//  AeroItin
//
//  Created by Matt Zayatz on 8/30/23.
//

import Foundation

extension DateFormatter {
    static var tripHeaderFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "yyyy MMM dd HH:mm"
        df.timeZone = .gmt
        return df
    }
    
    static var tripDayFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "EEEEEE"
        df.timeZone = .gmt
        return df
    }
}
