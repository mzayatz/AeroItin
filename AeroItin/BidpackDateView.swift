//
//  BidpackDateView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 9/23/23.
//

import SwiftUI

struct BidpackDateView: View, Equatable {
    let date: Date
    let timeZone: TimeZone
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Calendar.localCalendarFor(timeZone: timeZone).isDateInWeekend(date) ? .secondary.opacity(0.25) : .clear)
                .border(.secondary.opacity(0.6))
            Text(date.formatted(.dateTime.day().inTimeZone(timeZone)))
                .font(.callout)
                .foregroundColor(.secondary.opacity(0.6))
        }
    }
}

struct BidpackDateView_Previews: PreviewProvider {
    static var previews: some View {
        BidpackDateView(date: Date(), timeZone: .mem)
            .frame(width: 25, height: 25)
    }
}
