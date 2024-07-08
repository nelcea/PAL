//
//  AudioPlayer.swift
//  PALApp
//
//  Created by Eric Bariaux on 11/05/2024.
//

import Foundation
import AVFoundation

@MainActor
class AudioPlayer: NSObject, ObservableObject {
    
    private var player: AVAudioPlayer?
    
    @Published var playing = false
    
    // Used to notify UI it needs updating when playing e.g. for all time related information
    private var refreshTimer: Timer?
    
    var currentTime: Double {
        get {
            player?.currentTime ?? 0.0
        }
        set {
            guard newValue >= 0 && newValue <= self.totalTime else {
                return
            }
            self.player?.currentTime = newValue
            objectWillChange.send()
        }
    }
    
    var totalTime: Double {
        player?.duration ?? 0.0
    }
    
    func load(recording: Recording) {
        player = try? AVAudioPlayer(contentsOf: recording.fileURL)
        if let player {
            player.delegate = self
            player.prepareToPlay()
            objectWillChange.send()
        }
    }
    
    func playOrPause() {
        if playing {
            stop()
        } else {
            play()
        }
    }
    
    private func play() {
        if let player {
            player.play()
            playing = true
            refreshTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [self] _ in
                Task { @MainActor in
                    objectWillChange.send()
                }
            })
        }
    }
    
    func stop() {
        playing = false
        refreshTimer?.invalidate()
        refreshTimer = nil
        player?.stop()
    }

    func skipBackward() {
        self.currentTime = max(0, self.currentTime - 15.0)
    }
    
    func skipForward() {
        self.currentTime = min(self.currentTime + 30.0, self.totalTime)
    }
}

extension AudioPlayer: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            playing = false
        }
    }
}

extension AudioPlayer {
    var currentTimeAsString: String {
        if player == nil { return "" }
        return timeAsString(time: currentTime)
    }
    
    var totalTimeAsString: String {
        if player == nil { return "" }
        return timeAsString(time: totalTime)
    }
    
    var remainingTimeAsString: String {
        if player == nil { return "" }
        return "-\(timeAsString(time: totalTime - currentTime))"
    }

    private func timeAsString(time: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        return formatter.string(from: time) ?? ""
    }
}
