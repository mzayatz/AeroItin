//
//  Date.FormatStyle.DateStyle+inTimeZone.swift
//  AeroItin
//
//  Created by Matt Zayatz on 9/24/23.
//

import Foundation

extension Date.FormatStyle {
    func inTimeZone(_ timeZone: TimeZone) -> Date.FormatStyle {
        var newFormatStyle = self
        newFormatStyle.timeZone = timeZone
        return newFormatStyle
    }
}
