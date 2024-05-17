//
//  Friend.swift
//  PALApp
//
//  Created by Eric Bariaux on 27/04/2024.
//

import Foundation
import CoreBluetooth
import Combine
import AVFoundation

class Friend : WearableDevice, ObservableObject {
    private static let audioCharacteristicUUID = CBUUID(string: "19B10001-E8F2-537E-4F6C-D104768A1214")
    
    var id = UUID()
    @Published var batteryLevel: UInt8 = 0

    let name: String
    
    private var bleManager: BLEManager
    private var cancellable: Cancellable?

    @Published var isRecording = false
    private var recording: Recording?
    private var packetCount = 0
    private var incomingData = Data()

    
    required init(bleManager: BLEManager, name: String) {
        self.bleManager = bleManager
        self.name = name
        cancellable = bleManager.valueChanges.sink(receiveCompletion: { (error) in
        }, receiveValue: { [self] (value) in
            let uuid = value.0
            let data = value.1
            if uuid == CBUUID(string: "0x2A19") {
                batteryLevel = UInt8(littleEndian: data.withUnsafeBytes { $0.load(as: UInt8.self) })
                print("Received battery level \(batteryLevel)")
            } else if uuid == Friend.audioCharacteristicUUID {
                incomingData.append(data.advanced(by: 3))
                packetCount += 1
                if packetCount % 100 == 0 {
                    flushRecordingBuffer()
                }
            }
        })
    }

    static let scanServiceUUID: CBUUID = CBUUID(string: "19B10000-E8F2-537E-4F6C-D104768A1214")
    
    let notifyCharacteristicsUUIDs = [CBUUID(string: "0x2A19")]
   
    func start(recording: Recording) {
        self.recording = recording
        if recording.startRecording() {
            isRecording = true
            bleManager.setNotify(enabled: true, forCharacteristics: Friend.audioCharacteristicUUID)
        }
    }
    
    func stopRecording() {
        bleManager.setNotify(enabled: false, forCharacteristics: Friend.audioCharacteristicUUID)
        isRecording = false
        flushRecordingBuffer()
        recording?.closeRecording()
    }
    
    private func flushRecordingBuffer() {
        recording?.append(data: incomingData)
        incomingData.removeAll()
    }
}
