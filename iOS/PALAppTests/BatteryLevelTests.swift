//
//  BatteryLevelTests.swift
//  PALAppTests
//
//  Created by Eric Bariaux on 05/07/2024.
//

import XCTest
@testable import PALApp

final class BatteryLevelTests: XCTestCase {

    func testLevels() {
        XCTAssertEqual("battery.0percent", symbolNameFor(batteryLevel: 0))
        XCTAssertEqual("battery.0percent", symbolNameFor(batteryLevel: 14))
        XCTAssertEqual("battery.25percent", symbolNameFor(batteryLevel: 15))
        XCTAssertEqual("battery.25percent", symbolNameFor(batteryLevel: 39))
        XCTAssertEqual("battery.50percent", symbolNameFor(batteryLevel: 40))
        XCTAssertEqual("battery.50percent", symbolNameFor(batteryLevel: 64))
        XCTAssertEqual("battery.75percent", symbolNameFor(batteryLevel: 65))
        XCTAssertEqual("battery.75percent", symbolNameFor(batteryLevel: 90))
        XCTAssertEqual("battery.100percent", symbolNameFor(batteryLevel: 91))
        XCTAssertEqual("battery.100percent", symbolNameFor(batteryLevel: 100))
        XCTAssertEqual("battery.100percent", symbolNameFor(batteryLevel: 150))
    }
    
}
