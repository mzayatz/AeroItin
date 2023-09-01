//
//  DateError.swift
//  AeroItin
//
//  Created by Matt Zayatz on 8/31/23.
//

import Foundation

enum DateError: Error {
    case endDateOccursBeforeStartDate(String)
}
