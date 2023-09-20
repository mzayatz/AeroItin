//
//  Date+isWeekend.swift
//  AeroItin
//
//  Created by Matt Zayatz on 9/18/23.
//

import Foundation

extension Date {
    var isWeekend: Bool {
        Calendar.current.isDateInWeekend(self)
    }
}
