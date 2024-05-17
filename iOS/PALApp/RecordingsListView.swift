//
//  RecordingsListView.swift
//  PALApp
//
//  Created by Eric Bariaux on 05/05/2024.
//

import SwiftUI

struct RecordingsListView: View {
    @ObservedObject var recordingManager: RecordingManager
    
    var body: some View {
        List {
            ForEach(recordingManager.recordings) { recording in
                NavigationLink(recording.fileURL.lastPathComponent, value: recording)
            }
            .onDelete(perform: recordingManager.removeRecordings)
        }
        .navigationDestination(for: Recording.self) { recording in
            RecordingView(recording: recording)
        }
    }
}

#Preview {
    RecordingsListView(recordingManager: RecordingManager())
}
