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
    
    func centerPadding(toLength length: Int, withPad pad: any StringProtocol) -> String {
        guard length - self.count >= 0 else {
            return String(self).padding(toLength: length + 1, withPad: "", startingAt: 0)
        }
        var string = String(self)
        var left = false
        for x in 0...(length - self.count) {
            if left {
                string.insert(" ", at: string.startIndex)
            } else {
                string.append(" ")
            }
            left.toggle()
        }
        return string
    }
    
    var isDeadheadFlightCode: Bool {
        return String(self).contains(/[A-Z][A-Z]\d\d\d\d/)
    }
}
