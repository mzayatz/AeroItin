//
//  ParserError.swift
//  AeroItin
//
//  Created by Matt Zayatz on 8/29/23.
//

import Foundation

enum ParserError: Error {
    case sectionDividerNotFoundError
    case tokenNotFoundError
    case noTripsFoundError
    case maxLoopIterationsReachedInTripRowsParser
    case tripsSectionHeaderNotFound
    case bidMonthYearNotFound
}
