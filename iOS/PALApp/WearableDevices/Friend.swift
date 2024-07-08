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
import os

class Friend : WearableDevice, BatteryInformation, AudioRecordingDevice {
    let log = Logger(subsystem: "be.nelcea.PALApp", category: "Friend")
    
    private static let audioServiceUUID = CBUUID(string: "19B10000-E8F2-537E-4F6C-D104768A1214")
    private static let audioCharacteristicUUID = CBUUID(string: "19B10001-E8F2-537E-4F6C-D104768A1214")
    private static let audioCodecCharacteristicUUID = CBUUID(string: "19B10002-E8F2-537E-4F6C-D104768A1214")
    
    private var cancellable: Cancellable?
    
    @Published var batteryLevel: UInt8 = 0
    
    @Published var isRecording = false
    private var recording: Recording?
    
    private var codec: FriendCodec?
    
    private var lastPacketNumber: UInt16?
    private var packetsBuffer = [AudioPacket]()
    
    required init(bleManager: BLEManager, name: String) {
        super.init(bleManager: bleManager, name: name)
        cancellable = bleManager.valueChanges.sink(receiveCompletion: { (error) in
        }, receiveValue: { [weak self] (value) in
            let (uuid, data) = value
            
            switch uuid {
            case BatteryService.batteryLevelCharacteristicUUID:
                if let self {
                    self.batteryCharacteristicUpdated(data: data)
                }
            case Friend.audioCharacteristicUUID:
                if let self {
                    self.audioCharacteristicUpdated(data: data)
                }
            case Friend.audioCodecCharacteristicUUID:
                if let self {
                    self.audioCodecCharacteristicUpdated(data: data)
                }
            default:
                if let self {
                    self.log.warning("Received value for unknown characteristic UUID \(uuid)")
                }
            }
        })
    }
    
    deinit {
        self.log.debug("Friend deinit")
        cancellable?.cancel()
    }
    
    private func batteryCharacteristicUpdated(data: Data) {
        batteryLevel = UInt8(littleEndian: data.withUnsafeBytes { $0.load(as: UInt8.self) })
        log.info("Received battery level \(self.batteryLevel)")
    }
    
    private func audioCharacteristicUpdated(data: Data) {
        log.info("Received packet of size \(data.count)")
        guard data.count >= 3 else { return }
        // Starts at 0 on first notification, continues the sequence after a pause but I have seen a small gap
        let packetNumber = UInt16(littleEndian: data.withUnsafeBytes { $0.load(as: UInt16.self) })
        // Starts at 0
        let index = UInt8(littleEndian: data.advanced(by: 2).withUnsafeBytes {$0.load(as: UInt8.self) })
        
        log.info("Packet number \(packetNumber)")
        log.info("Index \(index)")
        
        if let lpn = lastPacketNumber {
            if packetNumber != lpn + 1 {
                log.warning("### Error, missing packet")
            }
        }
        lastPacketNumber = packetNumber
        
        if index == 0 {
            // Only flush if we're starting a new packet, otherwise we would split between packet content
            if packetsBuffer.count == 100 {
                flushRecordingBuffer()
            }
            packetsBuffer.append(AudioPacket(packetNumber: packetNumber))
        }
        if let packet = packetsBuffer.last {
            packet.append(data: data.advanced(by: 3))
        }
    }
    
    private func audioCodecCharacteristicUpdated(data: Data) {
        let codecType = UInt8(littleEndian: data.withUnsafeBytes { $0.load(as: UInt8.self) })
        codec = FriendCodec(rawValue: codecType)
        log.info("Codec type \(codecType)")
    }
    
    override class var deviceConfiguration: WearableDeviceConfiguration {
        return WearableDeviceConfiguration(
            reference: "Friend",
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
        lastPacketNumber = nil
    }
    
    private func flushRecordingBuffer() {
        recording?.append(packets: packetsBuffer)
        packetsBuffer.removeAll()
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
}
