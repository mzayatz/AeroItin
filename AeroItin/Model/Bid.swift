//
//  Bid.swift
//  AeroIitin
//
//  Created by Matt Zayatz on 4/22/23.
//

import Foundation

struct Bid {
    
    private let lineSelection: [String]
    private let settings: Settings
    
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
                settings.protectMinDaysForRecurrentTraining ? "Yes" : "No",
            waiveIntlBufferForReccurentTrainingCode:
                settings.waiveIntlBufferForReccurentTraining ? "Yes" : "No",
            waiveIntlBufferToAvoidPhaseInConflictCode:
                settings.waiveIntlBufferToAvoidPhaseInConflict ? "Yes" : "No",
            waive1in10LegalityToAvoidPhaseInConflictCode:
                settings.waive1in10LegalityToAvoidPhaseInConflict ? "Yes" : "No",
            protectMinDaysDueToCarryoverCode:
                settings.protectMinDaysDueToCarryover ? "Yes" : "No",
            unaskedOneCode: unaskedOne,
            unaskedTwoCode: unaskedTwo,
            unaskedThreeCode: unaskedThree
        ]
        
    }
    
    init(
        settings: Settings,
        lineSelection: [String]
    ) throws {
        self.settings = settings
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
        
        var postUrl = URL(string: "https://pilot.fedex.com/vips-bin/vipscgi?webmtb?\(settings.employeeNumber)?input")!
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
