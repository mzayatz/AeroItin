//
//  TabSettingsView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 12/14/23.
//

import SwiftUI

struct TabSettingsView: View {
    @State var employeeNumber = ""
    var body: some View {
        NavigationStack{
            Form {
                Section("Settings") {
                    TextField("Employee #:", text: $employeeNumber)
                }
            }.navigationTitle("Settings")
        }
    }
}

#Preview {
    TabSettingsView()
}
