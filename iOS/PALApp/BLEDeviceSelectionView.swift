//
//  BLEDeviceSelectionView.swift
//  PALApp
//
//  Created by Eric Bariaux on 06/05/2024.
//

import SwiftUI

struct BLEDeviceSelectionView: View {
    @ObservedObject var bleManager: BLEManager
    
    var body: some View {
        VStack {
            HStack {
                Text("Wearables")
                Spacer()
                switch bleManager.status {
                case .disconnected, .off, .on:
                    Button("Scan") {
                        bleManager.startScanning()
                    }
                case .scanning, .connecting:
                    Button("Stop") {
                        bleManager.stopScanning()
                    }
                case .connected, .linked:
                    Text("Connected")
                }
                Spacer()
                if bleManager.status == .scanning || bleManager.status == .connecting {
                    ProgressView()
                }
            }
            .padding(10)
            List {
                ForEach(bleManager.discoveredPeripherals) { peripheral in
                    Button(action: { () in connectToDeviceWith(id: peripheral.id)}) {
                        Text(peripheral.name)
                    }
                }
            }
        }
        .padding()
    }

    func connectToDeviceWith(id: UUID) {
        bleManager.connect(to: id)
    }

}

#Preview {
    BLEDeviceSelectionView(bleManager: BLEManager())
}
