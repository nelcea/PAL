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
        Button() {
            if device.isRecording {
                stopRecording()
            } else {
                startRecording()
            }
        } label: {
            Label(device.isRecording ? "stop" : "record", systemImage: device.isRecording ? "stop.circle" : "record.circle")
        }
        if device.isRecording {
            Text(stopwatch.formattedTime)
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
