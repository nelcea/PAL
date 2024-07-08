//
//  ConfigurationRepository.swift
//  PALApp
//
//  Created by Eric Bariaux on 05/07/2024.
//

import Foundation
import SwiftData

func getOrCreateConfiguration(modelContext: ModelContext) throws -> Configuration {
    var descriptor = FetchDescriptor<Configuration>()
    descriptor.fetchLimit = 1
    let configurations = try modelContext.fetch(descriptor)
    if let configuration = configurations.first {
        return configuration
    } else {
        let configuration = Configuration()
        modelContext.insert(configuration)
        return configuration
    }
}
