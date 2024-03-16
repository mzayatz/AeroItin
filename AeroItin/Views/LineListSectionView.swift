//
//  LineListSectionView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 10/23/23.
//

import SwiftUI

struct LineListSectionView: View {
    @EnvironmentObject var bidManager: BidManager
    let section: Line.Flag
    
    var sectionTitle: String {
        switch section {
        case .avoid:
            return "Avoids"
        case .bid:
            return "Bid"
        case .neutral:
            return "Lines"
        }
    }
    
    var filteredLines: [Line] {
//        let iatas = bidManager.searchFilter.components(separatedBy: .whitespaces).filter { $0.count == 3 }.map { $0.lowercased() }
//        
//        return bidManager.bidpack[keyPath: section.associatedArrayKeypath].filter { line in
//            let isCategoryFiltered = !bidManager.bidpack.categoryFilter.contains(line.category)
//            let isIATAMatched = line.layovers.contains { iatas.contains($0) }
//            return (iatas.isEmpty || isIATAMatched) && isCategoryFiltered
//        }
        let lines = bidManager.bidpack[keyPath:section.associatedArrayKeypath].filter { $0.category != .secondary }
        return lines.filter { line in
             // Check if any trip in the line conflicts with avoided dates
             let conflicts = line.trips.contains { trip in
                 bidManager.avoidedDates.contains { avoidedDate in
                     trip.startDate <= avoidedDate && trip.endDate >= avoidedDate
                 }
             }
             // If there are conflicts, filter out this line
             return !conflicts
         }
    }
    
    var body: some View {
        if(!bidManager.bidpack[keyPath: section.associatedArrayKeypath].isEmpty) {
            Section {
                ForEach(section != .neutral ? bidManager.bidpack[keyPath: section.associatedArrayKeypath] : filteredLines) { line in
                    HStack {
                        LineButton(line: line, action: section.plusTransferAction)
                        LineView(line: line)
                        LineButton(line: line, action: section.minusTransferAction)
                    }
                }.onMove {
                    bidManager.bidpack[keyPath: section.associatedArrayKeypath].move(fromOffsets: $0, toOffset: $1)
                }.moveDisabled(section == .neutral)
            } header: {
                HStack {
                    Text(bidManager.bidpack.sortDescending ? "⌄ descending" : "⌃ ascending").foregroundStyle(Color.accentColor)
                        .onTapGesture {
                            bidManager.bidpack.sortDescending.toggle()
                        }
                    Spacer()
                    Text("\(sectionTitle) \(bidManager.bidpack[keyPath: section.associatedArrayKeypath].count)")
                    Spacer()
                    Text("Bids").foregroundStyle(Color.accentColor)
                        .onTapGesture {
                            bidManager.scrollSnap = .bid
                        }
                    Text("Lines").foregroundStyle(Color.accentColor)
                        .onTapGesture {
                            bidManager.scrollSnap = .neutral
                        }
                    Text("Avoids").foregroundStyle(Color.accentColor)
                        .onTapGesture {
                            bidManager.scrollSnap = .avoid
                        }
                }
                
            }
        }
    }
}

//#Preview {
//    let bidManager = BidManager(seat: .firstOfficer)
//    return List { LineListSectionView(section: .neutral).environmentObject(bidManager) }
//}
