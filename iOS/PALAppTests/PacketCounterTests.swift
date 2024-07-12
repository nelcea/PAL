//
//  PacketCounterTests.swift
//  PALAppTests
//
//  Created by Eric Bariaux on 11/07/2024.
//

import XCTest
@testable import PALApp

final class PacketCounterTests: XCTestCase {

    func testValidOrder() throws {
        var pc = PacketCounter()
        try pc.checkPacketNumber(10)
        try pc.checkPacketNumber(11)
    }
    
    func testOverflow() throws {
        var pc = PacketCounter()
        try pc.checkPacketNumber(UInt16.max)
        try pc.checkPacketNumber(0)
    }
    
    func testMissingPacket() throws {
        var pc = PacketCounter()
        try pc.checkPacketNumber(10)
        do {
            try pc.checkPacketNumber(12)
            XCTFail("Should have thrown an error for the missing packet")
        } catch {
            let packetCounterError = error as? PacketCounterError
            XCTAssertNotNil(packetCounterError)
            XCTAssertTrue(packetCounterError == PacketCounterError.invalidSequenceNumber)
        }
    }
    
    func testReset() throws {
        var pc = PacketCounter()
        try pc.checkPacketNumber(10)
        pc.reset()
        try pc.checkPacketNumber(20)
    }
    
}
