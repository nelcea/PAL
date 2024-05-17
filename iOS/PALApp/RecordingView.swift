//
//  RecordingView.swift
//  PALApp
//
//  Created by Eric Bariaux on 30/04/2024.
//

import SwiftUI
import AVFoundation

struct RecordingView: View {
    
    var recording: Recording
    
    @StateObject var audioPlayer = AudioPlayer()

    var body: some View {
        VStack {
            Text(recording.fileURL.lastPathComponent)
            Text("\(recording.startDate, format: .dateTime)")
            Button(audioPlayer.playing ? "Stop" :"Play") {
                if audioPlayer.playing {
                    audioPlayer.stop()
                } else {
                    print("Trying to play \(audioPlayer.play())")
                }
            }
            .padding(10)
            // TODO: add a proper UI for a player, at least time information
            
            // TODO: add button to transcribe using ASR
            ShareLink(item: recording, preview: SharePreview("Share"))
                .padding(10)
        }
        .onAppear() {
            audioPlayer.load(recording: recording)

            recording.readInfo()
        }
    }
}

#Preview {
    RecordingView(recording: Recording(fileURL: URL(fileURLWithPath: "test.wav")))
}
