//
//  Stopwatch.swift
//  PALApp
//
//  Created by Eric Bariaux on 09/05/2024.
//

import Foundation

// TODO: removing that fixes concurrency warning but what about safety for UI updates
// TODO: check talk 10019 from WWDC2021
// Option 1: don't have @MainActor but what about safety for UI updates
// Option 2: have @MainActor but need to have a Task on main actor in the timer closure
@MainActor
class Stopwatch: ObservableObject {

    private var startTime: Date?
    private var timer: Timer?
    
    var refreshInternal: TimeInterval = 0.01
    
    @Published var time: TimeInterval = 0.0
    var formattedTime: String {
        Duration(timeInterval: time).formatted(.time(pattern: Duration.TimeFormatStyle.Pattern.minuteSecond(padMinuteToLength: 2, fractionalSecondsLength: 2)))
    }
    
    func start() {
        if let timer {
            timer.invalidate()
        }
        startTime = Date()
        // TODO: fix warnings using other method for periodic variable update
        timer = Timer.scheduledTimer(withTimeInterval: refreshInternal, repeats: true, block: { [self] _ in
            Task { @MainActor in
                if let startTime {
                    self.time = Date().timeIntervalSince(startTime)
                } else {
                    self.time = 0.0
                }
            }
        })
    }
    
    func stop() {
        timer?.invalidate()
        startTime = nil // TODO: if started then should be Date()
    }
}

extension Duration {
    init(timeInterval: TimeInterval) {
        let usecondsDuration = timeInterval.truncatingRemainder(dividingBy: 1) * 1_000_000
        self.init(timeval(tv_sec: Int(timeInterval), tv_usec:Int32(usecondsDuration)))
    }
}
