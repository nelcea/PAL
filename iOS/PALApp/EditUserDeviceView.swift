//
//  EditUserDeviceView.swift
//  PALApp
//
//  Created by Eric Bariaux on 26/07/2024.
//

import SwiftUI

struct EditUserDeviceView: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var userDevice: UserDevice?
    @State private var deviceName = ""

    var body: some View {
        Form {
            Section{
                TextField("Device name", text: $deviceName)
            } header: {
                Text("Name your device")
            } footer: {
                HStack {
                    Spacer()
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    Spacer()
                    Button("Confirm") {
                        if let userDevice {
                            userDevice.name = deviceName
                        }
                        userDevice = nil
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    Spacer()
                }
                .padding(.top, 20)
            }
        }
        .onAppear() {
            deviceName = userDevice?.name ?? "N/A"
        }
    }
}

#Preview {
    EditUserDeviceView(userDevice: .constant(UserDevice(name: "", deviceIdentifier: UUID(), deviceType: .localMicrophone)))
}
