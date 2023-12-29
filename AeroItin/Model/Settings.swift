//
//  Settings.swift
//  AeroItin
//
//  Created by Matt Zayatz on 12/17/23.
//

import Foundation

struct Settings: Codable {
    var employeeNumber = ""
    var seat: Bidpack.Seat = .firstOfficer
    var protectMinDaysForRecurrentTraining = false
    var waiveIntlBufferForReccurentTraining = false
    var waiveIntlBufferToAvoidPhaseInConflict = false
    var waive1in10LegalityToAvoidPhaseInConflict = false
    var protectMinDaysDueToCarryover = false
    
}
