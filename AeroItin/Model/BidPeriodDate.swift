//
//  BidPeriodDate.swift
//  AeroItin
//
//  Created by Matt Zayatz on 3/21/24.
//

import Foundation

struct BidPeriodDate: Codable, Equatable {
    let calendarDate: Date
    var category: DateCategory = .normal
    let isWeekend: Bool
    let formatted: String
    
    enum DateCategory: Codable {
        case normal
        case avoid
    }
    func resetCategory() -> BidPeriodDate {
        return BidPeriodDate(calendarDate: calendarDate, isWeekend: isWeekend, formatted: formatted)
    }
}

extension BidPeriodDate {
    init() {
        calendarDate = Date()
        category = .normal
        isWeekend = calendarDate.isWeekend
        formatted = calendarDate.formatted(.dateTime.day().inTimeZone(.mem))
    }
}
