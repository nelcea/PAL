//
//  RecordingManager.swift
//  PALApp
//
//  Created by Eric Bariaux on 29/04/2024.
//

import Foundation

class RecordingManager: ObservableObject {
    
    var wearable: WearableDevice?
    var device: AudioRecordingDevice? {
        wearable as? AudioRecordingDevice
    }

    var currentRecording: Recording?

    @Published var recordings: [Recording] = []
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func createRecording() -> Recording {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let timestamp = dateFormatter.string(from: Date())
        let recordingFileURL = getDocumentsDirectory().appendingPathComponent("Recording_\(timestamp).wav")

        return Recording(fileURL: recordingFileURL)
    }
    
    func add(recording: Recording) {
        recordings.append(recording)
    }
    
    func readRecordings() {
        print(getDocumentsDirectory())
        print(getDocumentsDirectory().path())
        let fm = FileManager.default
        do {
            let files = try fm.contentsOfDirectory(atPath: getDocumentsDirectory().path())
            for filename in files {
                recordings.append(Recording(fileURL: getDocumentsDirectory().appendingPathComponent(filename)))
            }
            recordings.sort { $0.startDate < $1.startDate }
        } catch {
            print (error.localizedDescription)
        }
    }
    
    func removeRecordings(at offsets: IndexSet) {
        for index in offsets {
            let recording = recordings.remove(at: index)
            do {
                try FileManager.default.removeItem(at: recording.fileURL)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func startRecording() {
        if let device {
            currentRecording = createRecording()
            device.start(recording: currentRecording!)
        }
    }
    
    func stopRecording() {
        if let device {
            device.stopRecording()
            if let r = currentRecording {
                add(recording: r)
                currentRecording = nil
            }
        }
    }
}
