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
        let iatas = bidManager.searchFilter.components(separatedBy: .whitespaces).filter { $0.count == 3 }.map { $0.lowercased() }
        
        return bidManager.bidpack[keyPath: section.associatedArrayKeypath].filter { $0.layovers.contains { iatas.contains($0) }
        }
    }
    
    
    var body: some View {
        if(!bidManager.bidpack[keyPath: section.associatedArrayKeypath].isEmpty) {
            Section(header: Text("\(sectionTitle) \(bidManager.bidpack[keyPath: section.associatedArrayKeypath].count)")) {
                ForEach(section != .neutral || filteredLines.isEmpty ? bidManager.bidpack[keyPath: section.associatedArrayKeypath] : filteredLines) { line in
                    HStack {
                        LineButton(line: line, action: section.plusTransferAction)
                        LineView(line: line)
                        LineButton(line: line, action: section.minusTransferAction)
                    }
                }.onMove { 
                    bidManager.bidpack[keyPath: section.associatedArrayKeypath].move(fromOffsets: $0, toOffset: $1)
                }.moveDisabled(!bidManager.searchFilter.isEmpty)
            }
        }
    }
}

#Preview {
    let bidManager = BidManager(seat: .firstOfficer)
    return List { LineListSectionView(section: .neutral).environmentObject(bidManager) }
}
