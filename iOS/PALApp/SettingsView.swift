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
    @State private var editedDevice: UserDevice?
    
    @State private var serverName = ""
    @Environment(\.modelContext) var modelContext
    @Query var devices: [UserDevice]
    
    @StateObject var recordingManager = RecordingManager()
    
    var body: some View {
        NavigationStack(path: $settingScrens) {
            List {
                Section("Wearable devices") {
                    ForEach(devices) { device in
                        HStack {
                            Text(device.name)
                            Spacer()
                            Button {
                                editedDevice = device
                                settingScrens = [.editDevice]
                            } label: {
                                Image(systemName: "info")
                            }
                        }
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
                        recordingManager.listRecordings(modelContext: modelContext)
                    }
                }
                
                Section {
                    #if os(iOS)
                    TextField("Server name", text: $serverName)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .onSubmit {
                            do {
                                let configuration = try getOrCreateConfiguration(modelContext: modelContext)
                                configuration.serverName = serverName
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    #else
                    TextField("Server name", text: $serverName)
                    // TODO: store servername -> in function
                    #endif
                    Button("Push to server") {
                        pushToServer()
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
                case .editDevice:
                    EditUserDeviceView(userDevice: $editedDevice)
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
            .task {
                do {
                    let configuration = try getOrCreateConfiguration(modelContext: modelContext)
                    
                    Task { @MainActor in
                        serverName = configuration.serverName ?? ""
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }

    enum SettingScreen {
        case addDevice
        case editDevice
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
    
    func pushToServer() {
        print("Push to server")
        do {
            let descriptor = FetchDescriptor<Recording>()
            let recordings = try modelContext.fetch(descriptor)
            
            let recordingsAPI = RecordingsAPI(serverName: serverName)
            
            Task {
                for recording in recordings {
                    let recordingExists = try await recordingsAPI.doesRecordingExistOnServer(recording: recording)
                    if !recordingExists {
                        print("Pushing \(recording.name)")
                        try await recordingsAPI.pushRecording(recording: recording)
                        
                    }
                    let audioExists = try await recordingsAPI.doesAudioExistOnServer(recording: recording)
                    if !audioExists {
                        try await recordingsAPI.pushAudio(recording: recording)
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
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
