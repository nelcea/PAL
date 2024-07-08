//
//  WearableDeviceSelectionView.swift
//  PALApp
//
//  Created by Eric Bariaux on 04/07/2024.
//

import SwiftUI

struct WearableDeviceSelectionView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var bleScanner = BLEScanner(deviceRegistry: WearableDeviceRegistry.shared)
    
    @Binding var selectedDevice: UserDevice?
    
    @State private var nameDevice = false
    @State private var tempDevice = DiscoveredDevice(name: "dummy", deviceIdentifier: UUID(), deviceType: .localMicrophone)
    
    var body: some View {
        Group {
            if nameDevice {
                VStack {
                    Form {
                        Section{
                            TextField("Device name", text: $tempDevice.name)
                        } header: {
                            Text("Name your device")
                        } footer: {
                            HStack {
                                Spacer()
                                Button("Cancel", role: .cancel) {
                                    dismiss()
                                }
                                .buttonStyle(.bordered)
                                Spacer()
                                Button("Confirm", action: confirmAdd)
                                    .buttonStyle(.bordered)
                                Spacer()
                            }
                            .padding(.top, 20)
                        }
                    }
                }
            } else {
                List {
                    HStack {
                        Text("Looking for wearables")
                            .padding(.trailing, 20)
                        ProgressView()
                    }
                    Section("Devices") {
                        ForEach(bleScanner.discoveredDevices) { device in
                            Button(action: { () in addDevice(device)}) {
                                Text(device.name)
                            }
                        }
                    }
                    Section {
                        HStack {
                            Spacer()
                            Button("Cancel") {
                                bleScanner.stopScanning()
                                dismiss()
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
        .navigationTitle("Add device")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    
    func addDevice(_ device: DiscoveredDevice) {
        bleScanner.stopScanning()
        tempDevice = device
        withAnimation {
            nameDevice = true
        }
    }
    
    func confirmAdd() {
        selectedDevice = UserDevice(name: tempDevice.name, deviceIdentifier: tempDevice.deviceIdentifier, deviceType: tempDevice.deviceType)
        dismiss()
    }
}

#Preview {
    WearableDeviceSelectionView(selectedDevice: .constant(UserDevice(name: "", deviceIdentifier: UUID(), deviceType: .localMicrophone)))
}
