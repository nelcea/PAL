//
//  PacketCounter.swift
//  PALApp
//
//  Created by Eric Bariaux on 11/07/2024.
//

import Foundation

struct PacketCounter {
    private var lastPacketNumber: UInt16?
    
    mutating func checkPacketNumber(_ packetNumber: UInt16) throws {
        if let lpn = lastPacketNumber {
            let packetNumberToCheck = (lpn == UInt16.max) ? 0 : lpn + 1
            if packetNumber != packetNumberToCheck {
                throw PacketCounterError.invalidSequenceNumber
            }
        }
        lastPacketNumber = packetNumber
    }
    
    mutating func reset() {
        lastPacketNumber = nil
    }
}

enum PacketCounterError: Error {
    case invalidSequenceNumber
}
