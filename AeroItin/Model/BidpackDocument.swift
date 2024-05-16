//
//  BidpackDocument.swift
//  AeroItin
//
//  Created by Matt Zayatz on 5/16/24.
//

import Foundation
import UniformTypeIdentifiers
import SwiftUI

struct BidpackDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    
    var bidpack: Bidpack
    
    init(bidpack: Bidpack) {
        self.bidpack = bidpack
    }
    
    init(configuration: ReadConfiguration) {
        guard let data = configuration.file.regularFileContents else {
            fatalError("could not parse bidpack")
        }
        do {
            let bidpack = try JSONDecoder().decode(Bidpack.self, from: data)
            self.bidpack = bidpack
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        do {
            return FileWrapper(regularFileWithContents: try JSONEncoder().encode(bidpack))
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
}
