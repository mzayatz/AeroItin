//
//  Trip.swift
//  AeroItin
//
//  Created by Matt Zayatz on 8/29/23.
//

import Foundation

struct Trip: CustomStringConvertible, Equatable, Codable {
    let text: [String]
    let number: String
    let effectiveDates: [Date]
    let creditHours: TimeInterval
    let blockHours: TimeInterval
    let landings: Int
    let timeAwayFromBase: TimeInterval
    let layovers: [String]
    let deadheads: Deadheads
    let isRfo: Bool
    
    static let dayAbbreviations = ["EXCEPT", "MO", "TU", "WE", "TH", "FR", "SA", "SU"]
    
    var shortDescription: String {
        layovers.isEmpty ? number : layovers.joined(separator: "-")
    }
    
    var startDateTime: Date {
        effectiveDates.first!
    }
    
    var endDateTime: Date {
        startDateTime.addingTimeInterval(timeAwayFromBase)
    }
    
    var startDate: Date {
        let components: Set<Calendar.Component> = [.year, .month, .day]
        return Calendar.zulu.date(from: Calendar.zulu.dateComponents(components, from: startDateTime))!
    }
    
    var endDate: Date {
        let components: Set<Calendar.Component> = [.year, .month, .day]
        return Calendar.zulu.date(from: Calendar.zulu.dateComponents(components, from: endDateTime))!
    }
    
    init() {
        text = [String]()
        number = ""
        effectiveDates = [Date]()
        creditHours = 0
        blockHours = 0
        landings = 0
        timeAwayFromBase = 0
        layovers = [String]()
        deadheads = .none
        isRfo = false
    }
    
    init(number: String, effectiveDate: Date, rdayValue: TimeInterval = 0) {
        text = ["\(number) Reserve"]
        self.number = number
        self.effectiveDates = [effectiveDate]
        creditHours = rdayValue
        blockHours = 0
        landings = 0
        timeAwayFromBase = .day
        layovers = [String]()
        deadheads = .none
        isRfo = false
    }
    
    init(trip: Trip, effectiveDate: Date) {
        text = trip.text
        number = trip.number
        effectiveDates = [effectiveDate]
        creditHours = trip.creditHours
        blockHours = trip.blockHours
        landings = trip.landings
        timeAwayFromBase = trip.timeAwayFromBase
        layovers = trip.layovers
        deadheads = trip.deadheads
        isRfo = trip.isRfo
    }
    
    init?(textRows: ArraySlice<String>, bidMonth: String, bidYear: String) {
        self.text = Array(textRows)
        guard var firstRowWords = self.text.first?.split(separator: " ").map(String.init),
              !firstRowWords.isEmpty
        else {
            assertionFailure("Problem reading first row of trip (Trip.swift)")
            return nil
        }
        number = firstRowWords.removeFirst()
        
        var daysOfWeek = [String]()
        
        var foundLastDay = false
        var maxLoopIterations = firstRowWords.count
        repeat {
            guard !firstRowWords.isEmpty && maxLoopIterations > 0 else {
                assertionFailure("Never exited daysOfWeek Loop (Trip.swift)")
                return nil
            }
            if Trip.dayAbbreviations.contains(firstRowWords.first!) {
                daysOfWeek.append(firstRowWords.removeFirst())
            } else {
                foundLastDay = true
            }
            maxLoopIterations -= 1
        } while !foundLastDay
        if daysOfWeek.first! == "EXCEPT" {
            daysOfWeek = Array(Set(Trip.dayAbbreviations).subtracting(daysOfWeek))
        }
        
        guard firstRowWords.count == 9 && firstRowWords.startIndex == 0 else {
            assertionFailure("Remaining words in trip header != 9 or startIndex != 0 (Trip.swift)")
            return nil
        }
        effectiveDates = Trip.computeValidDatesFrom(
            firstRowWords,
            bidMonth: bidMonth,
            bidYear: bidYear
        )!.filter {
            daysOfWeek.contains(DateFormatter.tripDayFormatter.string(from: $0).uppercased())
        }
        
        guard let lastRowWords = textRows.last?.split(separator: " ").map(String.init),
              lastRowWords.count == 10
        else {
            assertionFailure("Problem reading last row of trip (Trip.swift)")
            return nil
        }
        guard let creditHours = TimeInterval(fromTimeString: lastRowWords[2]),
              let blockHours = TimeInterval(fromTimeString: lastRowWords[5]),
              let landings = Int(lastRowWords[7]),
              let timeAwayFromBase = TimeInterval(fromTimeString: lastRowWords[9]) else {
            assertionFailure("Problem parsing last row of trip (Trip.swift)")
            return nil
        }
        self.creditHours = creditHours
        self.blockHours = blockHours
        self.landings = landings
        self.timeAwayFromBase = timeAwayFromBase
        
        self.layovers = Trip.findLayovers(in: textRows)
        self.deadheads = Trip.findDeadheads(in: textRows)
        
        self.isRfo = text[1].firstMatch(of: /1 RFO/) != nil

    }
    
    //TODO: This function fails to find backend deadhead in this circumstance:
    //TODO: The problem is the transportation information at the very bottom...
//    --------------------------------------------------------------------------------------------
//
//     Report for B777 schedule JUNE 2024                         MEM BASE  #    90
//        90 SU               REPORT AT  22:24 (17:24 L.T.)  EFFECTIVE JUN 09 ONLY
//     FULL CREW
//      DAY   FLT.  EQP  DEPARTS (L.T.)  ARRIVES (L.T.)  BLK.     BLK.   DUTY    CR.      LAYOVER
//     09SU   0038  F84  MEM 2324(1824)  CDG 0816(1016)  08:52 DH/BH
//                  BERCY PULLMAN 011-33-1-446-73402              08:52  10:22  08:52   CDG 40:44
//                  TRANS BY URBANRIDE-CHABE LIMO 011-331-4120-9510
//     12WE   5342  F83  CDG 0230(0430)  CAN 1509(2309)  12:39 BH/DH
//                  WHITE SWAN 011-86-20-8188-6968                12:39  14:09  12:39   CAN 26:11
//                  TRANS BY URBANRIDE, INC (FOR OTIS GROUP  212-920-8360
//      #TH   5608  F83  CAN 1850(0250)  NRT 2313(0813)  04:23 BSI
//                  HILTON NRT 011-81-476-33-1121 011-81-476-33-  04:23  05:53  04:23   NRT 57:57
//                  TRANS BY KEISEI TAXI NARITA 011-81-476-33-5405(RAMP)
//     16SU   5311  F83  NRT 1040(1940)  SIN 1757(0157)  07:17 DH
//                  FAIRMONT SINGAPORE HOTEL 011-65-6339-7777     07:17  08:47  07:17   SIN 37:53
//                  TRANS BY ALLIANCE TRANSPORTATION (URBAN  212-920-8360
//     18TU   5601  F83  SIN 0920(1720)  KIX 1541(0041)  06:21 DH
//                  SWISSOTEL OSAKA 011-81-6-6646-1111            06:21  07:51  06:21   KIX 31:00
//                  TRANS BY OSAKA DAIICHI KOUTSU. CO. LTD 011-81-72-434-0120 (Ramp)
//     20TH   5170  F83  KIX 0011(0911)  ANC 0739(2339)  07:28 BH
//                  CAPTAIN COOK 907-276-6000                     07:28  08:58  07:28   ANC 19:14
//                  TRANS BY BESPOKE TRANSPORTATION 212-203-0706
//      *FR   9731  F83  ANC 0423(2023)  NLU 1125(0525)  07:02 DH
//                  JW MARRIOTT MEX 011-52-555-999-0000           07:02  08:32  07:02   NLU 24:45
//                  TRANS BY TRANSPORTACIONES SERAFIN VALLE 011-52-555-175-0364
//     22SA GT9999  CAB  NLU 1240(0640)  MEX 1340(0740)  00:30
//     22SA DL0593  738  MEX 1440(0840)  ATL 1815(1415)  03:35
//     22SA DL0852  739  ATL 2016(1616)  MEM 2136(1636)  01:20
//                                                                00:00  09:26  05:25
//                  TRANS BY TRANSPORTACIONES SERAFIN VALLE 011-52-555-175-0364
//         CREDIT HRS:   85:46T    BLK HRS:  54:02     LDGS:   7      TAFB:   311:42
    
    static private func findDeadheads(in rows: ArraySlice<String>) -> Deadheads {
        let isFrontDeadhead = rows[rows.startIndex + 3].split(separator: " ")[1].isDeadheadFlightCode
        let isBackDeadhead = rows[rows.endIndex - 3].split(separator: " ")[1].isDeadheadFlightCode
        
        if isFrontDeadhead && isBackDeadhead {
            return .double
        } else if isFrontDeadhead {
            return .front
        } else if isBackDeadhead {
            return .back
        } else {
            return .none
        }
    }
    
    static private func findLayovers(in rows: ArraySlice<String>) -> [String] {
        var layovers = [String]()
        let regex = /(?P<iata>[A-Z]{3}) (?P<duration>\d\d:\d\d)/
        for layover in rows.joined().matches(of: regex) {
            layovers.append(String(layover.output.iata).lowercased())
        }
        return layovers
    }
    
    static private func computeValidDatesFrom(
        _ firstRowWords: [String],
        bidMonth: String,
        bidYear: String) -> [Date]?
    {
        let zuluStartTimeString = firstRowWords[2]
        let zuluStartingMonthString = firstRowWords[6]
        var zuluStartingDayWithMaybeEndingMonth = firstRowWords[7].components(separatedBy: "-")
        let zuluStartingDayString = zuluStartingDayWithMaybeEndingMonth.removeFirst()
        let zuluEndingMonthString = zuluStartingDayWithMaybeEndingMonth.last
        let zuluEndingDayString = firstRowWords[8] == "ONLY" ? nil : firstRowWords[8]
        guard (zuluEndingDayString == nil && zuluEndingMonthString == nil) ||
                (zuluEndingDayString != nil && zuluEndingMonthString != nil) else {
            assertionFailure("Problem parsing effective dates (Trip.swift)")
            return nil
        }
        
        guard let zuluStartingYearString = computeYear(
            bidMonth: bidMonth,
            bidYear: bidYear,
            tripMonth: zuluStartingMonthString) else
        {
            assertionFailure("computeYear function could not compute the trip start/end year")
            return nil
        }
        
        var validDates = [Date]()
        
        guard let startingDate = DateFormatter.tripHeaderFormatter.date(
            from:([zuluStartingYearString, 
                   zuluStartingMonthString,
                   zuluStartingDayString,
                   zuluStartTimeString].joined(separator: " ")
                 )) else 
        {
            assertionFailure("Problem creating date from starting effective date components")
            return nil
        }
        validDates.append(startingDate)
        
        if zuluEndingMonthString != nil {
            guard let zuluEndingYearString = computeYear(
                bidMonth: bidMonth,
                bidYear: bidYear,
                tripMonth: zuluEndingMonthString!) else
            {
                assertionFailure("computeYear function could not compute the trip start/end year")
                return nil
            }
            
            guard let endingDate = DateFormatter.tripHeaderFormatter.date(
                from:([zuluEndingYearString,
                       zuluEndingMonthString!,
                       zuluEndingDayString!, 
                       zuluStartTimeString].joined(separator: " ")
                     )) else
            {
                assertionFailure("Problem creating date from ending effective date components")
                return nil
            }
            guard startingDate < endingDate else {
                assertionFailure("starting effective date isn't less than ending effective date")
                return nil
            }
            guard let moreValidDates = try? Calendar.zulu.allDatesBetween(from: startingDate, to: endingDate) else {
                assertionFailure("a valid date was not properly computed in computeValidDatesFrom (Trip.swift).")
                return nil
            }
            validDates.append(contentsOf: moreValidDates)
        }
        
        return validDates
    }
    
    static private func computeYear(bidMonth: String, bidYear: String, tripMonth: String) -> String? {
        if bidMonth != "DECEMBER" && bidMonth != "JANUARY" {
            return bidYear
        }
        
        guard let intYear = Int(bidYear) else {
            assertionFailure("Could not convert string to integer in Trip.computeYear")
            return nil
        }
        
        if bidMonth == "DECEMBER" && tripMonth == "JAN" {
            return String(intYear + 1)
        }
        
        if bidMonth == "JANUARY" && tripMonth == "DEC" {
            return String(intYear - 1)
        }
        
        return bidYear
    }
    var description: String {
        "\(number)"
    }
    
    enum Deadheads: Codable {
        case double
        case front
        case back
        case none
    }
}
