//
//  Recording.swift
//  PALApp
//
//  Created by Eric Bariaux on 29/04/2024.
//

import Foundation
import AVFoundation
import CoreTransferable
import SwiftData

@Model
class Recording: Identifiable {

    var id = UUID()
    var filename: String
    var name: String
    var comment = ""
    var timestamp: Date
    var duration_: Double?
    
    var duration: Duration? {
        get {
            if let seconds = duration_ {
                return Duration.seconds(seconds)
            } else {
                return nil
            }
        }
        set {
            if let d = newValue {
                duration_ = d.inSeconds
            } else {
                duration_ = nil
            }
        }
    }

    @Transient var fileURL: URL {
        RecordingManager.getDocumentsDirectory().appendingPathComponent(filename)
    }

    @Transient private var audioFormat: AVAudioFormat?
    @Transient private var codec: Codec?
    @Transient private var recordingFile: AVAudioFile?
    
    init(filename: String) {
        self.filename = filename
        self.name = filename
        self.timestamp = Self.extractStartDate(filename: filename)
    }
    
    private static func extractStartDate(filename: String) -> Date {
        let timestampString = filename.deletingPrefix("Recording_").deletingSuffix(".wav")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        return dateFormatter.date(from: timestampString) ?? Date()
    }
    
    func readInfo() {
        if let file = try? AVAudioFile(forReading: fileURL) {
            duration = Duration.seconds(Double(file.length) / file.fileFormat.sampleRate)
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
    
    func append(packets: [AudioPacket]) {
        if let recordingFile, let codec {
            do {
                var decodedDataBlock = Data()
                for packet in packets {
                    try decodedDataBlock.append(codec.decode(data: packet.packetData))
                }
                let pcmBuffer = try codec.pcmBuffer(data: decodedDataBlock)
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


extension Recording: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Recording: Equatable {
    static func == (lhs: Recording, rhs: Recording) -> Bool {
        lhs.id == rhs.id
    }
}

extension Recording: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .wav) { recording in
            SentTransferredFile(recording.fileURL)
        } importing: { data in
            // TODO: write data to doc folder
            Recording(filename: "")
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

extension Duration {
    var inSeconds: Double {
        let v = components
        return Double(v.seconds) + Double(v.attoseconds) * 1e-18
    }
}
