//
//  WearableInfoView.swift
//  PALApp
//
//  Created by Eric Bariaux on 12/05/2024.
//

import SwiftUI

struct WearableInfoView: View {
    
    @ObservedObject var wearable: WearableDevice
    
    var body: some View {
        Text("Connected to \(wearable.name), battery \((wearable as? BatteryInformation)?.batteryLevel ?? 0) %")
    }
}

#Preview {
    WearableInfoView(wearable: Friend(bleManager: BLEManager(deviceRegistry: WearableDeviceRegistry.shared), name: "Friend"))
}
