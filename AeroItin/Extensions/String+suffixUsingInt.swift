//
//  String+offsetFromStart.swift
//  AeroItin
//
//  Created by Matt Zayatz on 11/17/23.
//

import Foundation

extension String {
    private func offsetFromStart(offsetBy: Int) -> String.Index {
        return self.index(self.startIndex, offsetBy: offsetBy)
    }
    private func suffixAsString(from index: String.Index) -> String {
        return String(self.suffix(from: index))
    }
    
    func suffixUsingInt(from int: Int) -> String {
        return self.suffixAsString(from: self.offsetFromStart(offsetBy: int))
    }
}
