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
    
    enum DateCategory: Codable {
        case normal
        case avoid
    }
    func resetCategory() -> BidPeriodDate {
        return BidPeriodDate(calendarDate: calendarDate, isWeekend: isWeekend)
    }
}

extension BidPeriodDate {
    init() {
        calendarDate = Date()
        category = .normal
        isWeekend = calendarDate.isWeekend
    }
}
