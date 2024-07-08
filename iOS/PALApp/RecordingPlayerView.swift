//
//  RecordingPlayerView.swift
//  PALApp
//
//  Created by Eric Bariaux on 18/06/2024.
//

import SwiftData
import SwiftUI

struct RecordingPlayerView: View {
    
    @StateObject var audioPlayer = AudioPlayer()

    var recording: Recording

    var body: some View {
        VStack {
            Text(recording.name)
                .font(.title3)
            Text(audioPlayer.totalTimeAsString)
            
            Slider(value: $audioPlayer.currentTime, in: 0...audioPlayer.totalTime)
            .padding([.top, .trailing, .leading], 25)
            
            HStack {
                Text(audioPlayer.currentTimeAsString)
                Spacer()
                Text(audioPlayer.remainingTimeAsString)
            }
            .padding(.horizontal, 25)

            HStack {
                Button(action: {
                    audioPlayer.skipBackward()
                }, label: {
                    Image(systemName: "gobackward.15").font(.title).foregroundColor(.primary)
                })
                Spacer()
                Button(action: {
                    audioPlayer.playOrPause()
                }, label: {
                    Image(systemName: audioPlayer.playing /*&& !vm.isFinished*/ ? "pause.fill" : "play.fill").font(.title).foregroundColor(.primary)
                })
                Spacer()
                Button(action: {
                    audioPlayer.skipForward()
                }, label: {
                    Image(systemName: "goforward.30").font(.title).foregroundColor(.primary)
                })
            }
            .padding(.horizontal, 50)
            .padding(.top, 20)
            Spacer()
        }
        .padding(.top, 10)
        .onAppear() {
            recording.readInfo()
            audioPlayer.load(recording: recording)
        }
        .onDisappear() {
            audioPlayer.stop()
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Recording.self, configurations: config)
        let example = Recording(filename: "test.wav")
        return RecordingPlayerView(recording: example)
            .modelContainer(container)
    } catch {
        fatalError("Failed to create model container.")
    }
}
