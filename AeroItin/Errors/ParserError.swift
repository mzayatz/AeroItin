//
//  ParserError.swift
//  AeroItin
//
//  Created by Matt Zayatz on 8/29/23.
//

import Foundation

enum ParserError: Error {
    case sectionDividerNotFoundError
    case tokenNotFoundError(String)
    case noTripsFoundError
    case maxLoopIterationsReachedInTripRowsParser
    case tripsSectionHeaderNotFound
    case bidMonthYearNotFound
    case tripCouldNotBeCreatedError(String)
    case maxLoopIterationsReachedInLineRowsParser
    case lineSectionHeaderNotFoundWithinFiveLinesOfSectionStart
    case lineSectionHeaderDateParsingError
    case lineCouldNotBeCreatedError(String)
}
