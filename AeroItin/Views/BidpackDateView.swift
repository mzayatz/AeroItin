//
//  BidpackDateView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 9/23/23.
//

import SwiftUI

struct BidpackDateView: View, Equatable {
    let date: BidPeriodDate
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(date.color)
                .border(.secondary.opacity(0.6))
            Text(date.formatted)
                .font(.footnote)
                .foregroundColor(.secondary.opacity(0.6))
        }
    }
}


//struct BidpackDateView_Previews: PreviewProvider {
//    static var previews: some View {
//        BidpackDateView(date: BidPeriodDate(), timeZone: .mem)
//            .frame(width: 25, height: 25)
//    }
//}
