//
//  TestLineView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 9/4/23.
//

import SwiftUI

struct TestLineView: View {
    let line: Line
    @EnvironmentObject var bidManager: BidManager
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(line.number): CH: \(line.summary.creditHours.asHours, format: .number.precision(.fractionLength(2))) - \(line.flag.rawValue)")
                Text("BH: \(line.summary.blockHours.asHours, format: .number.precision(.fractionLength(2))) - LDG: \(line.summary.landings) - Days off \(line.summary.daysOff)")
                Text("DPs: \(line.summary.dutyPeriods)")
            }
            Text("✅").onTapGesture {
                bidManager.bidLine(line: line)
            }
            Text("⛔️").onTapGesture {
                bidManager.avoidLine(line: line)
            }
            Text("↩️").onTapGesture {
                bidManager.resetLine(line: line)
            }
            Text("⬆️").onTapGesture {
                bidManager.moveLineUpOne(line: line)
            }
            Text("⬇️").onTapGesture {
                bidManager.moveLineDownOne(line: line)
            }
        }.background(backgroundColor.opacity(0.25))
    }
    
    var backgroundColor: Color {
        switch line.flag {
        case .avoid:
            return Color.red
        case .neutral:
            return Color.white
        case .bid:
            return Color.green
        }
    }
}

struct TestLineView_Previews: PreviewProvider {
    @StateObject static var manager = BidManager(seat: .firstOfficer)
    static var previews: some View {
        TestLineView(line: manager.bidpack.lines.randomElement()!).environmentObject(manager)
    }
}
