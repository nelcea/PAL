//
//  RecorderView.swift
//  PALApp
//
//  Created by Eric Bariaux on 05/05/2024.
//

import SwiftUI

struct RecorderView: View {
    
    @ObservedObject var bleManager: BLEManager
    @ObservedObject var wearable: Friend
    @ObservedObject var recordingManager: RecordingManager

    @ObservedObject var stopwatch =  Stopwatch()
    
    var body: some View {
        Button() {
            if wearable.isRecording {
                stopRecording()
            } else {
                startRecording()
            }
        } label: {
            Label(wearable.isRecording ? "stop" : "record", systemImage: wearable.isRecording ? "stop.circle" : "record.circle")
        }
        if wearable.isRecording {
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
