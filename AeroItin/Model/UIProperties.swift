//
//  UIProperties.swift
//  AeroItin
//
//  Created by Matt Zayatz on 5/21/24.
//

import Foundation

public struct UIProperties {
    let dateCount: Int
    
    init(dateCount: Int) {
        self.dateCount = dateCount
    }
    
    init() {
        self.dateCount = 28
    }
    
    let lineHeight: CGFloat = 35
    let lineLabelWidth: CGFloat = 60
    let sensibleScreenWidth: CGFloat = 1000
    
}
