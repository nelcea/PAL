//
//  WearableDevice.swift
//  PALApp
//
//  Created by Eric Bariaux on 27/04/2024.
//

import Foundation
import CoreBluetooth

protocol WearableDevice: ObservableObject {
    
    init(bleManager: BLEManager, name: String)
    
    // TODO: should group all of this in some form of configuration, which is a static property
    
    /// UUID of service that identifies the device when scanning for BLE peripherals
    static var scanServiceUUID: CBUUID { get }
    
    /// UUID of characterstics for which it wants a notification (from the start)
    var notifyCharacteristicsUUIDs: [CBUUID] { get }
        
    var id: UUID { get }   
    
    var batteryLevel: UInt8 { get }
    
    var isRecording: Bool { get }
    
    func start(recording: Recording)

    func stopRecording()
    
}
