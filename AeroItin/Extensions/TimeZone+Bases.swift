//
//  TimeZone+Bases.swift
//  AeroItin
//
//  Created by Matt Zayatz on 8/30/23.
//

import Foundation

extension TimeZone {
    
    static var mem: TimeZone {
        .init(identifier: "America/Chicago")!
    }
    static var ind: TimeZone {
        .init(identifier: "America/Indiana/Indianapolis")!
    }
    static var anc: TimeZone {
        .init(identifier: "America/Anchorage")!
    }
    static var lax: TimeZone {
        .init(identifier: "America/Los_Angeles")!
    }
    static var oak: TimeZone {
        .init(identifier: "America/Los_Angeles")!
    }
    static var eur: TimeZone {
        .init(identifier: "Europe/Paris")!
    }
    
}
