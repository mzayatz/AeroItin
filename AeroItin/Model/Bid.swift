//
//  Bid.swift
//  AeroIitin
//
//  Created by Matt Zayatz on 4/22/23.
//

import Foundation

struct Bid {
    
    private let employeeNumber: String
    private let protectMinDaysForRecurrentTraining: Bool
    private let waiveIntlBufferForReccurentTraining: Bool
    private let waiveIntlBufferToAvoidPhaseInConflict: Bool
    private let waive1in10LegalityToAvoidPhaseInConflict: Bool
    private let protectMinDaysDueToCarryover: Bool
    private let lineSelection: [String]
    
    private let unaskedOne = "Unasked"
    private let unaskedTwo = "Unasked"
    private let unaskedThree = "Unasked"
    private let submit = "+++Submit+++"
    
    private let protectMinDaysForRecurrentTrainingCode = "n002"
    private let waiveIntlBufferForReccurentTrainingCode = "n003"
    private let waiveIntlBufferToAvoidPhaseInConflictCode = "n004"
    private let waive1in10LegalityToAvoidPhaseInConflictCode = "n005"
    private let protectMinDaysDueToCarryoverCode = "n006"
    private let unaskedOneCode = "n007"
    private let unaskedTwoCode = "n008"
    private let unaskedThreeCode = "n009"
    private let submitCode = "n999"
   
    private var answers: [String: String] {
        [
            protectMinDaysForRecurrentTrainingCode:
                protectMinDaysForRecurrentTraining ? "Yes" : "No",
            waiveIntlBufferForReccurentTrainingCode:
                waiveIntlBufferForReccurentTraining ? "Yes" : "No",
            waiveIntlBufferToAvoidPhaseInConflictCode:
                waiveIntlBufferToAvoidPhaseInConflict ? "Yes" : "No",
            waive1in10LegalityToAvoidPhaseInConflictCode:
                waive1in10LegalityToAvoidPhaseInConflict ? "Yes" : "No",
            protectMinDaysDueToCarryoverCode:
                protectMinDaysDueToCarryover ? "Yes" : "No",
            unaskedOneCode: unaskedOne,
            unaskedTwoCode: unaskedTwo,
            unaskedThreeCode: unaskedThree
        ]
        
    }
    
    init(
        employeeNumber: String,
        protectMinDaysForRecurrentTraining: Bool,
        waiveIntlBufferForReccurentTraining: Bool,
        waiveIntlBufferToAvoidPhaseInConflict: Bool,
        waive1in10LegalityToAvoidPhaseInConflict: Bool,
        protectMinDaysDueToCarryover: Bool, lineSelection: [String]
    ) throws {
        self.protectMinDaysForRecurrentTraining = protectMinDaysForRecurrentTraining
        self.waiveIntlBufferForReccurentTraining = waiveIntlBufferForReccurentTraining
        self.waiveIntlBufferToAvoidPhaseInConflict = waiveIntlBufferToAvoidPhaseInConflict
        self.waive1in10LegalityToAvoidPhaseInConflict = waive1in10LegalityToAvoidPhaseInConflict
        self.protectMinDaysDueToCarryover = protectMinDaysDueToCarryover
        self.employeeNumber = employeeNumber
        if lineSelection.count > 0 && lineSelection.count < 491 {
            self.lineSelection = lineSelection
        }
        else {
            throw BidError.numberOfLinesBidError(lineSelection.count)
        }
    }
    
    private func createBidDictionary() -> [String: String] {
        var bidDictionary = createEmptyBidDictionary()
        bidDictionary.merge(answers) { (_ , new) in new }
        
        for (i, line) in lineSelection.enumerated() {
            let key = "n\(i + 101)"
            bidDictionary[key] = line
        }
        return bidDictionary
    }
    
    func createPostRequest() -> URLRequest {
        var items = URLComponents()
        let bidDictionary = createBidDictionary()
        items.queryItems = [URLQueryItem]()
        
        for k in bidDictionary.keys.sorted() {
            items.queryItems!.append(URLQueryItem(name: k, value: bidDictionary[k]))
        }
        
        var postUrl = URL(string: "https://pilot.fedex.com/vips-bin/vipscgi?webmtb?\(employeeNumber)?input")!
        postUrl.append(queryItems: items.queryItems!)
        var request = URLRequest(url: postUrl)
        request.httpMethod = "POST"
        request.httpBody = items.percentEncodedQuery?.data(using: .utf8)
        return request
    }
    
    private func createEmptyBidDictionary() -> [String: String] {
        var bidDictionary = [String: String]()
        
        for x in 2...9 {
            let key = "n00\(x)"
            bidDictionary[key] = ""
        }
        
        for x in 101...490 {
            let key = "n\(x)"
            bidDictionary[key] = ""
        }
        
        bidDictionary[submitCode] = submit
        return bidDictionary
    }
}
