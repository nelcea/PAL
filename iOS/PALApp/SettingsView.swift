//
//  SettingsView.swift
//  PALApp
//
//  Created by Eric Bariaux on 02/07/2024.
//

import SwiftData
import SwiftUI

struct SettingsView: View {
    @ObservedObject var bleManager: BLEManager
    
    @Binding var isShowingSettings: Bool
    
    @State private var settingScrens: [SettingScreen] = []
    
    @State private var selectedDevice: UserDevice?
    
    @Environment(\.modelContext) var modelContext
    @Query var devices: [UserDevice]
    
    @StateObject var recordingManager = RecordingManager()
    
    var body: some View {
        NavigationStack(path: $settingScrens) {
            List {
                Section("Wearable devices") {
                    ForEach(devices) { device in
                        Text(device.name)
                    }
                    .onDelete(perform: deleteDevice)
                }
                Section {
                    Button("Add", action: addDevice)
                }
                
                // Should display a list of devices
                // And have a button to add a device -> starts scanning for devices
                // Once user has selected a device, option for user to name it
                // In list, user should be able to delete/forget device and also to edit its name
                
                Section {
                    Button("Sync DB") {
                        // Should only add, never delete
                        recordingManager.syncDatabase(modelContext: modelContext)
                        
                        // TODO: display list of added recordings
                        
                    }
                    Button("List recordings") {
                        recordingManager.listRecordings()
                    }
                }
                
                Section {
                    Button("Ping server") {
                        // TODO: try to connect to server
                        
                        // Eventually, should also allow to define the server address
                    }
                }
            }
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .topBarLeading) {
                    Button() {
                        isShowingSettings = false
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                #endif
            }
            .toolbarTitleDisplayMode(.inline)
            .navigationTitle("Settings")
            .navigationDestination(for: SettingScreen.self) { screen in
                switch(screen) {
                case .addDevice:
                    WearableDeviceSelectionView(selectedDevice: $selectedDevice)
                }
            }
            .onChange(of: selectedDevice) {
                if let device = selectedDevice {
                    modelContext.insert(device)
                    selectedDevice = nil
                    do {
                        let configuration = try getOrCreateConfiguration(modelContext: modelContext)
                        if configuration.selectedDevice == nil {
                            configuration.selectedDevice = device
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }

    enum SettingScreen {
        case addDevice
    }

    func addDevice() {
        settingScrens = [.addDevice]
    }
    
    func deleteDevice(_ indexSet: IndexSet) {
        for index in indexSet {
            let device = devices[index]
            modelContext.delete(device)
            do {
                let configuration = try getOrCreateConfiguration(modelContext: modelContext)
                if configuration.selectedDevice == device {
                    bleManager.disconnect()
                    if let otherDevice = devices.first(where: { $0 != device } ) {
                        configuration.selectedDevice = otherDevice
                    } else {
                        configuration.selectedDevice = nil
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Configuration.self, UserDevice.self, configurations: config)
        return SettingsView(bleManager: BLEManager(deviceRegistry: WearableDeviceRegistry.shared),
                            isShowingSettings: .constant(true))
            .modelContainer(container)
    } catch {
        fatalError("Failed to create model container.")
    }
}
