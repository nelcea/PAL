//
//  RecordingPlayerView.swift
//  PALApp
//
//  Created by Eric Bariaux on 18/06/2024.
//

import SwiftUI

struct RecordingPlayerView: View {
    
    @StateObject var audioPlayer = AudioPlayer()

    var recording: Recording

    var body: some View {
        // TODO: add a proper UI for a player, at least time information
        VStack {
            Button(audioPlayer.playing ? "Stop" :"Play") {
                if audioPlayer.playing {
                    audioPlayer.stop()
                } else {
                    print("Trying to play \(audioPlayer.play())")
                }
            }
        }
        .onAppear() {
            recording.readInfo()
            audioPlayer.load(recording: recording)
        }
    }
}

#Preview {
    RecordingPlayerView(recording: Recording(fileURL: URL(fileURLWithPath: "test.wav")))
}
