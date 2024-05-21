//
//  SettingsManager.swift
//  AeroItin
//
//  Created by Matt Zayatz on 5/20/24.
//

import Foundation

class SettingsManager: ObservableObject {
    
    var settings = Settings()
    var settingsUrl = URL.documentsDirectory.appending(component: "settings.json")

    func load() async throws {
        let task = Task<Settings, Error> {
            guard let data = try? Data(contentsOf: settingsUrl) else {
                return Settings()
            }
            let settings = try JSONDecoder().decode(Settings.self, from: data)
            return settings
        }
        settings = try await task.value
    }
    
    func save() async throws {
        let task = Task {
            let data = try JSONEncoder().encode(settings)
            try data.write(to: settingsUrl)
        }
        _ = try await task.value
        
    }
}
