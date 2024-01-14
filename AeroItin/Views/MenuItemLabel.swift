//
//  MenuItemLabel.swift
//  AeroItin
//
//  Created by Matt Zayatz on 1/14/24.
//

import SwiftUI

struct MenuItemLabel: View {
    let text: String
    let imageSystemName: String
    var body: some View {
        HStack {
            Text(text)
            Image(systemName: imageSystemName)
        }
    }
}

#Preview {
    Menu {
        Button { } label: {
            MenuItemLabel(text: "Save", imageSystemName: "square.and.arrow.down")
        }
    } label: {
        Text("Menu")
    }
}
