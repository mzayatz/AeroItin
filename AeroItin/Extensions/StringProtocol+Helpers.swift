//
//  StringProtocol+Helpers.swift
//  AeroItin
//
//  Created by Matt Zayatz on 8/31/23.
//

import Foundation

extension StringProtocol {
    var isInt: Bool {
        return Int(self) != nil
    }
    
    var isIata: Bool {
        guard self.count == 3 else {
            return false
        }
        return self.allSatisfy {
            $0.isLetter
        }
    }
    
    func leftPadding(toLength length: Int, withPad pad: any StringProtocol, startingAt start: Int) -> String {
        return String(String(self.reversed()).padding(toLength: length, withPad: pad, startingAt: start).reversed())
    }
    
    var isDeadheadFlightCode: Bool {
        return String(self).contains(/[A-Z][A-Z]\d\d\d\d/)
    }
}
