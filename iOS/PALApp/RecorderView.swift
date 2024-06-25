//
//  RecorderView.swift
//  PALApp
//
//  Created by Eric Bariaux on 05/05/2024.
//

import SwiftUI

struct RecorderView: View {
    
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
        recordingManager.stopRecording()
    }
}

/*
 #Preview {
 RecorderView()
 }
 */
