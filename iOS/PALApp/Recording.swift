//
//  Recording.swift
//  PALApp
//
//  Created by Eric Bariaux on 29/04/2024.
//

import Foundation
import AVFoundation
import CoreTransferable

class Recording: Identifiable, Hashable {
    
    static func == (lhs: Recording, rhs: Recording) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id = UUID()
    var fileURL: URL
    
    private var audioFormat: AVAudioFormat?
    private var recordingFile: AVAudioFile?
    
    init(fileURL: URL) {
        self.fileURL = fileURL
    }
    
    var startDate: Date {
        let timestampString = fileURL.lastPathComponent.deletingPrefix("Recording_").deletingSuffix(".wav")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        return dateFormatter.date(from: timestampString) ?? Date()
    }
    
    var duration: Duration?
    
    func readInfo() {
        if let file = try? AVAudioFile(forReading: fileURL) {
            let secondsDuration = Double(file.length) / file.fileFormat.sampleRate
            let usecondsDuration = secondsDuration.truncatingRemainder(dividingBy: 1) * 1_000_000
            duration = Duration(timeval(tv_sec: Int(secondsDuration), tv_usec:Int32(usecondsDuration)))
        }
    }
    
    func startRecording() -> Bool {
        let sampleRate: Double = 8000
        audioFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: sampleRate, channels: 1, interleaved: false)
        guard let audioFormat else { return false }
        recordingFile = try? AVAudioFile(forWriting: fileURL, settings: audioFormat.settings)
        return recordingFile != nil
    }
    
    func append(data: Data) {
        if let audioFormat, let recordingFile {
            guard let pcmBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: UInt32(data.count / MemoryLayout<Int16>.size)) else {
                print("Error creating PCM buffer")
                return
            }
            
            pcmBuffer.frameLength = pcmBuffer.frameCapacity
            
            let u16array = data.withUnsafeBytes {
                Array($0.bindMemory(to: Int16.self)).map(Int16.init(littleEndian:))
            }
            
            /*
             This normalisation by block does not work, it makes the noise stand out way too much
            let factor = max(abs(u16array.min()!), u16array.max()!)
            let f32Array = u16array.map({(Float32($0) / Float32(factor))})
             */
            let f32Array = u16array.map({Float32($0) / 32768})

            let channels = UnsafeBufferPointer(start: pcmBuffer.floatChannelData, count: Int(pcmBuffer.format.channelCount))
            
            let floatData = f32Array.withUnsafeBufferPointer( { Data(buffer: $0 )})
            
            UnsafeMutableRawPointer(channels[0]).withMemoryRebound(to: UInt8.self, capacity: data.count * 2) {
                (bytes: UnsafeMutablePointer<UInt8>) in
                floatData.copyBytes(to: bytes, count: floatData.count)
            }
            
            do {
                try recordingFile.write(from: pcmBuffer)
                print("Saved a block of \(pcmBuffer.frameLength) samples")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func closeRecording() {
        recordingFile = nil
    }
}

extension Recording: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .wav) { recording in
            SentTransferredFile(recording.fileURL)
        } importing: { data in
            // TODO: write data to doc folder
            Recording(fileURL: URL(filePath: ""))
        }
    }
    
}

extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
    
    func deletingSuffix(_ suffix: String) -> String {
        guard self.hasSuffix(suffix) else { return self }
        return String(self.dropLast(suffix.count))
    }
}
