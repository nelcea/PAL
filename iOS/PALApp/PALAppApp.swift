//
//  PALAppApp.swift
//  PALApp
//
//  Created by Eric Bariaux on 27/04/2024.
//

import SwiftData
import SwiftUI

@main
struct PALAppApp: App {
    
    init() {
        WearableDeviceRegistry.shared.registerDevice(wearable: Friend.self)
        WearableDeviceRegistry.shared.registerDevice(wearable: PAL.self)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Configuration.self, Recording.self, UserDevice.self])
        #if os(macOS)
        Settings {
            SettingsView(bleManager: BLEManager(deviceRegistry: WearableDeviceRegistry.shared), isShowingSettings: .constant(true))
        }
        .modelContainer(for: [Configuration.self, Recording.self, UserDevice.self])
        #endif
    }
}
