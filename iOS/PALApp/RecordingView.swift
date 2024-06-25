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
        TabView {
            RecordingInfoView(recording: recording)
            RecordingPlayerView(recording: recording)
            RecordingTranscriptionView(recording: recording)
        }
        #if os(iOS)
        .tabViewStyle(.page)
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        #endif
        .onAppear() {
            audioPlayer.load(recording: recording)

            recording.readInfo()
        }
        .navigationTitle(recording.fileURL.lastPathComponent)
    }
}

#Preview {
    RecordingView(recording: Recording(fileURL: URL(fileURLWithPath: "test.wav")))
}
