//
//  AudioPlayer.swift
//  PALApp
//
//  Created by Eric Bariaux on 11/05/2024.
//

import Foundation
import AVFoundation

@MainActor
class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    private var player: AVAudioPlayer?
    
    @Published var playing = false
    
    func load(recording: Recording) {
        player = try? AVAudioPlayer(contentsOf: recording.fileURL)
        if let p = player {
            p.delegate = self
        }
    }
    
    func play() {
        if let player {
            player.play()
            playing = true
        }
    }
    
    func stop() {
        playing = false
        player?.stop()
    }
    
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            playing = false
        }
    }
    
}
