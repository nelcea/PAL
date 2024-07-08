//
//  RecordingsListView.swift
//  PALApp
//
//  Created by Eric Bariaux on 05/05/2024.
//

import SwiftData
import SwiftUI

struct RecordingsListView: View {
    @ObservedObject var recordingManager: RecordingManager
    
    @Query(sort: \Recording.timestamp) var recordings: [Recording]
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        List {
            ForEach(recordings) { recording in
                NavigationLink(recording.name, value: recording)
            }
            .onDelete(perform: removeRecordings)
        }
        .navigationDestination(for: Recording.self) { recording in
            RecordingView(recording: recording)
        }
    }
    
    func removeRecordings(_ indexSet: IndexSet) {
        for index in indexSet {
            let recording = recordings[index]
            recordingManager.removeRecording(modelContext: modelContext, recording: recording)
        }
    }
}

#Preview {
    RecordingsListView(recordingManager: RecordingManager())
}
