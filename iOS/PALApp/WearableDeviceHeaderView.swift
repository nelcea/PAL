//
//  WearableDeviceHeaderView.swift
//  PALApp
//
//  Created by Eric Bariaux on 05/07/2024.
//

import SwiftUI

struct WearableDeviceHeaderView: View {
    
    @ObservedObject var wearable: WearableDevice
    
    private var batterySymbolName: String {
        if let w = wearable as? BatteryInformation {
            return symbolNameFor(batteryLevel: w.batteryLevel)
        }
        return "exclamationmark.octagon"
    }

    var body: some View {
        HStack {
            Text(wearable.name)
                .font(.title3)
                .padding(.trailing, 10)
            Image(systemName: "link")
                .padding(.trailing, 30)
            Image(systemName: batterySymbolName)
        }
    }
}

func symbolNameFor(batteryLevel: UInt8) -> String {
    switch batteryLevel {
    case 0..<15:
        return "battery.0percent"
    case 15..<40:
        return "battery.25percent"
    case 40..<65:
        return "battery.50percent"
    case 65..<91:
        return "battery.75percent"
    default:
        return "battery.100percent"
    }
}

#Preview {
    WearableDeviceHeaderView(wearable: Friend(bleManager: BLEManager(deviceRegistry: WearableDeviceRegistry.shared), name: "Friend"))
}
