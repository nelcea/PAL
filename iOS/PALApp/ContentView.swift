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
    
    var body: some View {
        NavigationStack {
            VStack {
                /*
                 Header should display either:
                    - No recording device selected if user has never selected a recording device
                    - The device but some disconnected indicator if a device is selected but not currently connected
                    - The device, a connected symbol and more information (e.g. battery level) if device is connected
                    - It should be possible for user to tap to selected another device
                 */
                if selectedDevice != nil {
                    if let wearable {
                        WearableDeviceHeaderView(wearable: wearable)
                        RecorderView(bleManager: bleManager, wearable: wearable, recordingManager: recordingManager)
                    } else {
                        HStack {
                            Text(selectedDevice!.name)
                                .font(.title3)
                                .padding(.trailing, 20)
                            ProgressView()
                        }
                    }
                    Spacer()
                } else {
                    Text("No recording device selected")
                    Text("Go to Settings to select one")
                    // TODO: should have link here to go to add device directly
                }
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
                #endif
            }
        }
        .padding(10)
        .sheet(isPresented: $isShowingSettings, onDismiss: {
            checkSelectedDeviceFromConfiguration()
        }) {
            SettingsView(bleManager: bleManager, isShowingSettings: $isShowingSettings)
        }
        .onChange(of: bleManager.status) {
            if bleManager.status == .linked {
                if let device = bleManager.connectedDevice {
                    wearable = device
                    recordingManager.wearable = wearable
                }
            } else if bleManager.status == .disconnected {
                recordingManager.stopRecording(modelContext: modelContext)
                wearable = nil
                recordingManager.wearable = nil
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
