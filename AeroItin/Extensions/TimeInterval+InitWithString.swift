//
//  TimeInterval+InitWithString.swift
//  FastBid
//
//  Created by Matt Zayatz on 3/13/23.
//

import Foundation

extension TimeInterval {
    init?(fromTimeString timeString: String) {
        let components = timeString.components(separatedBy: ":")
        guard let hours = Double(components[0]),
              let minutes = Double(components[1].trimmingCharacters(in: .letters)),
              components.count == 2 else {
            return nil
        }
        self.init(hours * 3600 + minutes * 60)
    }
    
    var asMinutes: Double {
        self / 60
    }
    
    var asHours: Double {
        self.asMinutes / 60
    }

    var asDays: Double {
        self.asHours / 24
    }
    
}
