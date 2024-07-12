//
//  ContentView.swift
//  PALApp
//
//  Created by Eric Bariaux on 27/04/2024.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) var modelContext

    @StateObject var recordingManager = RecordingManager()
    @StateObject var bleManager = BLEManager(deviceRegistry: WearableDeviceRegistry.shared)

    @State var selectedDevice: UserDevice?
    @State var wearable: WearableDevice?

    @State var isShowingSettings = false
    
    @Query var devices: [UserDevice]
    @State var isSelectingDevice = false

    var body: some View {
        NavigationStack {
            VStack {
                
                // TODO: have this in a private view
                // TODO: have row more stable, format / icon locations should be identical irrelevant of state, going a bit all over the place
                
                if selectedDevice != nil {
                    HStack {
                        Text(selectedDevice!.name)
                            .font(.title3)
                            .padding(.trailing, 20)
                        if let wearable {
                            WearableDeviceHeaderView(wearable: wearable)
                        } else {
                            if bleManager.status == .connecting {
                                ProgressView()
                                    .padding(.trailing, 30)
                                Button() {
                                    bleManager.stopConnecting()
                                } label: {
                                    Image(systemName: "stop.circle")
                                }
                            } else {
                                ZStack {
                                    ProgressView().hidden()
                                    Image(systemName: "wifi.slash")
                                }
                                .padding(.trailing, 30)
                                Button() {
                                    bleManager.reconnect(to: selectedDevice!.deviceIdentifier)
                                } label: {
                                    Image(systemName: "arrow.clockwise")
                                }
                            }
                        }
                        if devices.count > 1 {
                            Button() {
                                isSelectingDevice = true
                            } label: {
                                Image(systemName: "chevron.forward")
                            }
                        }
                    }
                } else {
                    Text("No recording device selected")
                    Text("Go to Settings to select one")
                    // TODO: should have link here to go to add device directly
                }
                if selectedDevice != nil, let wearable {
                    RecorderView(bleManager: bleManager, wearable: wearable, recordingManager: recordingManager)
                }
                Spacer()
                RecordingsListView(recordingManager: recordingManager)
            }
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isShowingSettings.toggle()
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                }
                ToolbarItemGroup {
                    Text(String(describing: bleManager.status)) // TODO: remove, only for debug
                }
                #endif
            }
        }
        .padding(10)
        .sheet(isPresented: $isShowingSettings, onDismiss: {
            checkSelectedDeviceFromConfiguration()
        }) {
            SettingsView(bleManager: bleManager, isShowingSettings: $isShowingSettings)
        }
        .sheet(isPresented: $isSelectingDevice) {
            List {
                ForEach(devices) { device in
                    Button() {
                        do {
                            let configuration = try getOrCreateConfiguration(modelContext: modelContext)
                            configuration.selectedDevice = device
                            checkSelectedDeviceFromConfiguration()
                        } catch {
                            print(error.localizedDescription)
                        }
                        isSelectingDevice = false
                    } label: {
                        HStack {
                            Text(device.name)
                            if device == selectedDevice {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .onChange(of: bleManager.status) {
            if bleManager.status == .linked {
                if let device = bleManager.connectedDevice {
                    wearable = device
                    recordingManager.wearable = wearable
                }
            } else if bleManager.status == .disconnected {
                if wearable != nil {
                    recordingManager.stopRecording(modelContext: modelContext)
                    wearable = nil
                    recordingManager.wearable = nil
                    checkSelectedDeviceFromConfiguration()
                }
            } else if bleManager.status == .on {
                checkSelectedDeviceFromConfiguration()
            }
        }
        .onAppear() {
            checkSelectedDeviceFromConfiguration()
        }
    }
    
    private func checkSelectedDeviceFromConfiguration() {
        do {
            let configuration = try getOrCreateConfiguration(modelContext: modelContext)
            if let newDevice = configuration.selectedDevice {
                if let oldDevice = selectedDevice {
                    if newDevice != oldDevice {
                        disconnect()
                        selectDevice(newDevice)
                    }
                } else {
                    selectDevice(newDevice)
                }
            } else {
                selectedDevice = nil
                disconnect()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func selectDevice(_ newDevice: UserDevice) {
        selectedDevice = newDevice
        bleManager.reconnect(to: newDevice.deviceIdentifier)
    }
    
    private func disconnect() {
        bleManager.disconnect()
        wearable = nil
    }
}

#Preview {
    ContentView()
}
