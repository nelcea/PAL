//
//  RecorderView.swift
//  PALApp
//
//  Created by Eric Bariaux on 05/05/2024.
//

import SwiftData
import SwiftUI

struct RecorderView: View {
    @Environment(\.modelContext) var modelContext
    
    @ObservedObject var bleManager: BLEManager
    @ObservedObject var wearable: WearableDevice
    var device: AudioRecordingDevice {
        wearable as! AudioRecordingDevice
    }

    @ObservedObject var recordingManager: RecordingManager

    @ObservedObject var stopwatch =  Stopwatch()

    var body: some View {
        switch (wearable.status) {
        case .ready:
            HStack {
                Button() {
                    if device.isRecording {
                        stopRecording()
                    } else {
                        startRecording()
                    }
                } label: {
                    RecordingButton(isRecording: device.isRecording)
                }
                Text(device.isRecording ? stopwatch.formattedTime : "")
                    .font(Font.largeTitle.monospacedDigit())
            }
        case .error(let message):
            Text(message)
        }
    }
    
    private func startRecording() {
        recordingManager.startRecording()
        stopwatch.start()
    }
    
    private func stopRecording() {
        stopwatch.stop()
        recordingManager.stopRecording(modelContext: modelContext)
    }
}

struct RecordingButton: View {
    
    var isRecording: Bool
    
    var body: some View {
        ZStack {
            Color.gray
                .frame(width: 40, height: 40)
                .clipShape(.circle)
            Color.white
                .frame(width: 36, height: 36)
                .clipShape(.circle)
            let size = isRecording ? 20.0 : 32.0
            Color.red
                .frame(width: size, height: size)
                .clipShape(isRecording ? AnyShape(RoundedRectangle(cornerRadius: 5)) : AnyShape(Circle()))
        }
    }
    
}


 #Preview {
     do {
         let config = ModelConfiguration(isStoredInMemoryOnly: true)
         let container = try ModelContainer(for: Recording.self, configurations: config)
         let example = Recording(filename: "test.wav")
         return RecordingView(recording: example)
             .modelContainer(container)
     } catch {
         fatalError("Failed to create model container.")
     }
 }
