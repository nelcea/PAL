//
//  WearableDevice.swift
//  PALApp
//
//  Created by Eric Bariaux on 27/04/2024.
//

import Foundation
import CoreBluetooth

class WearableDevice: ObservableObject {
    
    var name: String
    var bleManager: BLEManager
    var id = UUID()
    
    required init(bleManager: BLEManager, name: String) {
        self.bleManager = bleManager
        self.name = name
    }
    
    class var deviceConfiguration: WearableDeviceConfiguration {
        return WearableDeviceConfiguration(scanServiceUUID: CBUUID(), notifyCharacteristicsUUIDs: [])
    }

}

struct WearableDeviceConfiguration {
    /// UUID of service that identifies the device when scanning for BLE peripherals
    var scanServiceUUID: CBUUID
    
    /// UUID of characterstics for which it wants a notification (from the start)
    var notifyCharacteristicsUUIDs: [CBUUID]
}

protocol BatteryInformation {
    
    var batteryLevel: UInt8 { get }

}

protocol AudioRecordingDevice {

    var isRecording: Bool { get }
    
    func start(recording: Recording)

    func stopRecording()

}
