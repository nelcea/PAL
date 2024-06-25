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

class Friend : WearableDevice, BatteryInformation, AudioRecordingDevice {
    private static let audioServiceUUID = CBUUID(string: "19B10000-E8F2-537E-4F6C-D104768A1214")
    private static let audioCharacteristicUUID = CBUUID(string: "19B10001-E8F2-537E-4F6C-D104768A1214")
    private static let audioCodecCharacteristicUUID = CBUUID(string: "19B10002-E8F2-537E-4F6C-D104768A1214")

    private var cancellable: Cancellable?

    @Published var batteryLevel: UInt8 = 0

    @Published var isRecording = false
    private var recording: Recording?
    private var packetCount = 0
    private var incomingData = Data()
    private var codec: FriendCodec?

    
    required init(bleManager: BLEManager, name: String) {
        super.init(bleManager: bleManager, name: name)
        cancellable = bleManager.valueChanges.sink(receiveCompletion: { (error) in
        }, receiveValue: { [self] (value) in
            let uuid = value.0
            let data = value.1
            if uuid == BatteryService.batteryLevelCharacteristicUUID {
                batteryLevel = UInt8(littleEndian: data.withUnsafeBytes { $0.load(as: UInt8.self) })
                print("Received battery level \(batteryLevel)")
            } else if uuid == Friend.audioCharacteristicUUID {
                guard data.count >= 3 else { return }
                let packetNumber = UInt16(littleEndian: data.withUnsafeBytes { $0.load(as: UInt16.self) })
                let index = UInt8(littleEndian: data.advanced(by: 2).withUnsafeBytes {$0.load(as: UInt8.self) })
                print("Packet number \(packetNumber)")
                // Starts at 0 on first notification, continues the sequence after a pause but I have see a small gap
                print("Index \(index)")
                
                incomingData.append(data.advanced(by: 3))
                packetCount += 1
                if packetCount % 100 == 0 {
                    flushRecordingBuffer()
                }
            } else if uuid == Friend.audioCodecCharacteristicUUID {
                let codecType = UInt8(littleEndian: data.withUnsafeBytes { $0.load(as: UInt8.self) })
                codec = FriendCodec(rawValue: codecType)
                print("Codec type \(codecType)")
            }
        })
    }

    override class var deviceConfiguration: WearableDeviceConfiguration {
        return WearableDeviceConfiguration(
            scanServiceUUID: audioServiceUUID,
            notifyCharacteristicsUUIDs: [BatteryService.batteryLevelCharacteristicUUID])
    }
   
    func start(recording: Recording) {
        self.recording = recording
        guard let audioCodec = codec?.codec else { return }
        if recording.startRecording(usingCodec: audioCodec) {
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

enum FriendCodec: UInt8 {
    case pcm16 = 0, pcm8
    case µLaw16 = 10, µLaw8
    case opus16 = 20
    
    var codec: Codec {
        switch self {
        case .pcm8:
            return PcmCodec(sampleRate: 8000.0)
        case .µLaw8:
            return µLawCodec(sampleRate: 8000.0)
        case .pcm16:
            return PcmCodec(sampleRate: 16000.0)
        case .µLaw16:
            return µLawCodec(sampleRate: 16000.0)
        case .opus16:
            return OpusCodec(sampleRate: 16000.0)
        }
    }
}
