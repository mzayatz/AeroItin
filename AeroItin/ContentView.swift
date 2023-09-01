//
//  ContentView.swift
//  AeroItin
//
//  Created by Matt Zayatz on 8/29/23.
//

import SwiftUI

struct ContentView: View {
    let bidPack: Bidpack
    
    static let filenames = [
        "2023_Sep_MD11_MEM_LINES",
        "2023_Sep_A300_MEM_LINES",
        "2023_Sep_B757_EUR_LINES",
        "2023_Sep_B757_MEM_LINES",
        "2023_Sep_B767_IND_LINES",
        "2023_Sep_B767_MEM_LINES",
        "2023_Sep_B767_OAK_LINES",
        "2023_Sep_B777_ANC_LINES",
        "2023_Sep_B777_MEM_LINES",
        "2023_Sep_MD11_ANC_LINES",
        "2023_Sep_MD11_LAX_LINES"
    ]
    static let urls = filenames.map {
        Bundle.main.url(forResource: $0, withExtension: testBidpackExtension)
    }
    static let testBidpackExtension = "asc"
    static let testBidpackUrl =
    Bundle.main.url(forResource: Bidpack.testBidpackFilename, withExtension: Bidpack.testBidpackExtension)!
    
    init() {
        do {
            for url in ContentView.urls {
                try Bidpack(with: url!)
            }
            try bidPack = Bidpack()
        }
        catch ParserError.sectionDividerNotFoundError {
            fatalError("SectionDividerNotFound Error... quitting.")
        }
        catch ParserError.tokenNotFoundError {
            fatalError("Token not found... quitting.")
        }
        catch {
            fatalError("Other error!\n\(error)")
        }
    }
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
