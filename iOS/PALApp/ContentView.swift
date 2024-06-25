//
//  ContentView.swift
//  PALApp
//
//  Created by Eric Bariaux on 27/04/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject var recordingManager = RecordingManager()
    @StateObject var bleManager = BLEManager()
    
    @State var wearable: WearableDevice?

    @State var isSelectingDevice = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if let wearable {
                    WearableInfoView(wearable: wearable)
                    RecorderView(bleManager: bleManager, wearable: wearable, recordingManager: recordingManager)
                } else {
                    Text("No recording device selected")
                    Button("Select device") {
                        bleManager.resetDiscoveredDevices()
                        isSelectingDevice = true
                    }
                }
                RecordingsListView(recordingManager: recordingManager)
            }
        }
        .padding(10)
        .sheet(isPresented: $isSelectingDevice) {
            BLEDeviceSelectionView(bleManager: bleManager)
        }
        .onAppear() {
            bleManager.registerDevice(wearable: Friend.self)
            bleManager.registerDevice(wearable: PAL.self)
            recordingManager.readRecordings()
        }
        .onChange(of: bleManager.status) {
            if bleManager.status == .linked {
                if let device = bleManager.connectedDevice {
                    wearable = device
                    isSelectingDevice = false
                    recordingManager.wearable = wearable
                }
            } else if bleManager.status == .disconnected {
                recordingManager.stopRecording()
                wearable = nil
                recordingManager.wearable = nil
            }
        }
    }
}

#Preview {
    ContentView()
}
