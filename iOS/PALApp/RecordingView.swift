//
//  RecordingView.swift
//  PALApp
//
//  Created by Eric Bariaux on 30/04/2024.
//

import SwiftData
import SwiftUI
import AVFoundation

struct Card: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.black)
            )
            .padding(.top, 10)
            .padding(.horizontal, 15)
            .padding(.bottom, 50)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(Card())
    }
}

struct RecordingView: View {
    
    var recording: Recording
    
    @StateObject var audioPlayer = AudioPlayer()

    var body: some View {
        TabView {
            RecordingInfoView(recording: recording)
                .cardStyle()
            RecordingPlayerView(recording: recording)
                .cardStyle()
            RecordingTranscriptionView(recording: recording)
                .cardStyle()
        }
        .navigationTitle(recording.name)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .tabViewStyle(.page)
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        #endif
        .onAppear() {
            audioPlayer.load(recording: recording)

            recording.readInfo()
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
