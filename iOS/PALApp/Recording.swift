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
    private var codec: Codec?
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
    
    func startRecording(usingCodec codec: Codec) -> Bool {
        self.codec = codec
        audioFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: codec.sampleRate, channels: 1, interleaved: false)
        
        let recordingFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: codec.sampleRate, channels: 1, interleaved: false)
        guard let recordingFormat else { return false }
        recordingFile = try? AVAudioFile(forWriting: fileURL, settings: recordingFormat.settings, commonFormat: .pcmFormatInt16, interleaved: false)
        return recordingFile != nil
    }
    
    // data must contain audio in Int16, little endian
    func append(data: Data) {
        if let recordingFile, let codec {
            do {
                let pcmBuffer = try codec.pcmBuffer(data: data)
                try recordingFile.write(from: pcmBuffer)
                print("Saved a block of \(pcmBuffer.frameLength) samples")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func closeRecording() {
        recordingFile = nil
        codec = nil
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
