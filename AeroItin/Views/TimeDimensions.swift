//
//  TimeDimensions.swift
//  AeroItin
//
//  Created by Matt Zayatz on 5/19/24.
//

import Foundation

struct TimeDimensions {
    let availableWidth: CGFloat
    let dayCount: Int
    
    var dayWidth: CGFloat {
        availableWidth / CGFloat(dayCount)
    }
    
    var hourWidth: CGFloat {
        dayWidth / 24
    }
    
    var minuteWidth: CGFloat {
        dayWidth / (24 * 60)
    }
    
    var secondWidth: CGFloat {
        dayWidth / (24 * 3600)
    }
}

