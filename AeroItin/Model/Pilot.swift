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
    let payOnlyOrFlex: Bool
    
    var id: String {
        employeeNumber
    }
    
    init(name: String,
         employeeNumber: String,
         senority: String,
         awardedLine: String,
         payOnlyOrFlex: Bool
    ) {
        self.name = name
        self.employeeNumber = employeeNumber
        self.senority = senority
        if awardedLine.starts(with: /[45]/) {
            self.awardedLine = String("S\(Int(awardedLine.dropFirst(1))!)")
        } else {
            self.awardedLine = awardedLine
        }
        self.payOnlyOrFlex = payOnlyOrFlex
    }
    
}

extension Pilot {
    init(awardedLine: String) {
        name = "Error!"
        employeeNumber = "9999999"
        senority = "9999"
        payOnlyOrFlex = false
        self.awardedLine = awardedLine
    }
}
