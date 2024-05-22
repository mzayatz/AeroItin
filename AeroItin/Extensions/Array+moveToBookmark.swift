//
//  Array+moveToBookmark.swift
//  AeroItin
//
//  Created by Matt Zayatz on 5/21/24.
//

import Foundation

extension Array where Element: Equatable {
    mutating func moveElementToIndex(element: Element, index: Array.Index) {
        guard index <= self.endIndex && index >= self.startIndex else {
              return
        }
        if let elementIndex = self.firstIndex(of: element) {
            self.move(fromOffsets: [elementIndex], toOffset: index)
        }
    }
}
