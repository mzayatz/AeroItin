//
//  Pilot.swift
//  AeroItin
//
//  Created by Matt Zayatz on 5/27/24.
//

import Foundation

struct Pilot: Codable, Identifiable, Equatable {
    let name: String
    let employeeNumber: String
    let senority: String
    let awardedLine: String
    
    var id: String {
        employeeNumber
    }
}
