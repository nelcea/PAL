//
//  DeviceView.swift
//  PALApp
//
//  Created by Eric Bariaux on 27/04/2024.
//

import SwiftUI

struct DeviceView: View {
    @Binding var path: [UUID]
    
    @ObservedObject var bleManager: BLEManager
    @ObservedObject var wearable: Friend
    
    @State var recordingManager = RecordingManager()
    
    @State var viewingRecording = false
    @State var selectedRecording: Recording?
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                if bleManager.status == .connected || bleManager.status == .linked {
                    Text("Connected")
                } else {
                    Text("Connecting")
                }
            }
            Spacer()
            Button() {
                if wearable.isRecording {
                    wearable.stopRecording()
                } else {
                    wearable.start(recording: recordingManager.createRecording())
                }
            } label: {
                Label(wearable.isRecording ? "stop" : "record", systemImage: wearable.isRecording ? "stop.circle" : "record.circle")
            }

            // Have a list of recordings, for now built from the files listing
            List {
                ForEach(recordingManager.recordings) { recording in
                    Button(action: { () in viewRecording(recording) }) {
                        Text(recording.fileURL.lastPathComponent)
                    }
                }
            }
            
            Text("Battery level \(wearable.batteryLevel)")
            Button("Back") {
                path.removeAll()
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear() {
            recordingManager.readRecordings()
        }
        .sheet(isPresented: $viewingRecording) {
            if let selectedRecording {
                RecordingView(recording: selectedRecording)
            } else {
                EmptyView()
            }
        }
    }
                           
    func viewRecording(_ recording: Recording) {
        selectedRecording = recording
        viewingRecording = true
    }
}

