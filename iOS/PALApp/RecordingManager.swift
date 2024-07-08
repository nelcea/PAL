//
//  RecordingManager.swift
//  PALApp
//
//  Created by Eric Bariaux on 29/04/2024.
//

import Foundation
import SwiftData

// TODO: with SwiftData, what's now the role of RecordingManager

class RecordingManager: ObservableObject {

    var wearable: WearableDevice?
    var device: AudioRecordingDevice? {
        wearable as? AudioRecordingDevice
    }

    var currentRecording: Recording?
   
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func createRecording() -> Recording {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let timestamp = dateFormatter.string(from: Date())

        return Recording(filename: "Recording_\(timestamp).wav")
    }
    
    private func add(modelContext: ModelContext, recording: Recording) {
        modelContext.insert(recording)
    }
    
    func listRecordings() {
        let fm = FileManager.default
        do {
            let files = try fm.contentsOfDirectory(atPath: Self.getDocumentsDirectory().path())
            for filename in files {
                print(Self.getDocumentsDirectory().appendingPathComponent(filename))
            }
        } catch {
            print (error.localizedDescription)
        }
    }
    
    func syncDatabase(modelContext: ModelContext) {
        let fm = FileManager.default
        do {
            let files = try fm.contentsOfDirectory(atPath: Self.getDocumentsDirectory().path())
            for filename in files {
                let descriptor = FetchDescriptor<Recording>(
                    predicate: #Predicate { $0.filename == filename }
                )
                let recordings = try modelContext.fetch(descriptor)
                if recordings.isEmpty {
                    print("Missing DB entry \(filename)")
                    let recording = Recording(filename: filename)
                    recording.readInfo()
                    modelContext.insert(recording)
                }
            }
        } catch {
            print (error.localizedDescription)
        }
    }
    
    func removeRecording(modelContext: ModelContext, recording: Recording) {
        do {
            modelContext.delete(recording)
            try FileManager.default.removeItem(at: recording.fileURL)
        } catch {
            print(error.localizedDescription)
        }
    }

    func startRecording() {
        if let device {
            currentRecording = createRecording()
            device.start(recording: currentRecording!)
        }
    }
    
    // TODO: we're adding in DB only when we stop but file got created ealier
    // how do we manage potential discrepency
    
    func stopRecording(modelContext: ModelContext) {
        if let device {
            device.stopRecording()
            if let r = currentRecording {
                add(modelContext: modelContext, recording: r)
                currentRecording = nil
            }
        }
    }
}
