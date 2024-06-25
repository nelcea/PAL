//
//  PAL.swift
//  PALApp
//
//  Created by Eric Bariaux on 27/04/2024.
//

import Foundation
import CoreBluetooth

class PAL : WearableDevice {
    var batteryLevel: UInt8 = 0

    override class var deviceConfiguration: WearableDeviceConfiguration {
        return WearableDeviceConfiguration(
            scanServiceUUID: CBUUID(string: "D860A1D3-736F-473A-8B27-C0DA611B61D2"),
            notifyCharacteristicsUUIDs: [])
    }
    
    var isRecording: Bool {
        return false
    }

    func start(recording: Recording) {
    }
    
    func stopRecording() {
        
    }

}
