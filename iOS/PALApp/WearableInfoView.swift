//
//  WearableInfoView.swift
//  PALApp
//
//  Created by Eric Bariaux on 12/05/2024.
//

import SwiftUI

struct WearableInfoView: View {
    
    @ObservedObject var wearable: Friend
    
    var body: some View {
        Text("Connected to \(wearable.name), battery \(wearable.batteryLevel) %")
    }
}

#Preview {
    WearableInfoView(wearable: Friend(bleManager: BLEManager(), name: "Friend"))
}
