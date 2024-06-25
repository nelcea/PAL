//
//  RecordingTranscriptionView.swift
//  PALApp
//
//  Created by Eric Bariaux on 18/06/2024.
//

import SwiftUI
import Speech

@MainActor
struct RecordingTranscriptionView: View {
    
    var recording: Recording

    // Locale.current.identifier = en_BE
    // Locale.current.language.minimalIdentifier = en-BE
    @State var recognizerLocale = Locale.current.language.minimalIdentifier
    @State var transcribing = false
    @State var transcribedText = ""
    
    @State var task: SFSpeechRecognitionTask?
    
    let preferredLocales: [LocaleInfo] = {
        var res = [LocaleInfo]()
        for locale in Locale.preferredLanguages {
            if let name = Locale.current.localizedString(forIdentifier: locale) {
                res.append(LocaleInfo(identifier: locale, name: name))
            }
        }
        return res
    }()

    var body: some View {
        VStack {
            Picker("Select language for recognition", selection: $recognizerLocale) {
                ForEach(preferredLocales) {
                    Text($0.name)
                        .tag($0.identifier)
                }
            }
            // TODO: way to select from Locale.availableIdentifiers

            HStack {
                Spacer()
                Button(transcribing ? "Stop" : "Start") {
                    if transcribing {
                        stopTranscribing()
                    } else {
                        transcribe()
                    }
                }
                Spacer()
                if transcribing {
                    ProgressView()
                }
                Spacer()
            }

            Text(transcribedText)
                .padding(10)
        }
    }
    
    func transcribe() {
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: recognizerLocale))

        Task {
            await SFSpeechRecognizer.hasAuthorizationToRecognize()
        }
        
        if let recognizer {
            if !recognizer.supportsOnDeviceRecognition {
                // TODO: proper interaction with the user
                print("No local recognition")
                return
            }
            transcribing = true
            
            recognizer.defaultTaskHint = .dictation
            
            let request = SFSpeechURLRecognitionRequest(url: recording.fileURL)
            request.requiresOnDeviceRecognition = true
            request.shouldReportPartialResults = false
            
            task = recognizer.recognitionTask(with: request, resultHandler: { result, error in
                if let error {
                    print(error) // Can I check on cancel and set transcribing = false here
                    // Error Domain=kLSRErrorDomain Code=301 "Recognition request was canceled" UserInfo={NSLocalizedDescription=Recognition request was canceled}
                    print("Error \(error.localizedDescription)")
                } else {
                    if let result {
                        print(result.bestTranscription.formattedString)
                        
                        //print(result.bestTranscription.formattedString)
                        Task { @MainActor in
                            // transcribedText = result.bestTranscription.formattedString
                            if result.isFinal {
                                // Also just getting the last sentence if only displaying on final
                                // TODO -> query perplexity
                                transcribedText = result.bestTranscription.formattedString
                                print("Final")
                                print(transcribedText)
                                transcribing = false
                            }
                        }
                    }
                }
            })

        }
    }
    
    func stopTranscribing() {
        if let task {
            task.cancel()
            self.task = nil
        }
        transcribing = false
    }
}

extension SFSpeechRecognizer {
    static func hasAuthorizationToRecognize() async -> Bool {
        await withCheckedContinuation { continuation in
            requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}

struct LocaleInfo: Identifiable {
    var identifier: String
    var name: String
    
    var id: String { identifier }
}

#Preview {
    RecordingTranscriptionView(recording: Recording(fileURL: URL(fileURLWithPath: "test.wav")))
}
