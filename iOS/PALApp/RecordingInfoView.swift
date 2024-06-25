//
//  RecordingInfoView.swift
//  PALApp
//
//  Created by Eric Bariaux on 19/06/2024.
//

import SwiftUI

struct RecordingInfoView: View {
    
    var recording: Recording

    var body: some View {
        VStack {
            Text(recording.fileURL.lastPathComponent)
            Text("\(recording.startDate, format: .dateTime)")

            ShareLink(item: recording, preview: SharePreview("Share"))
                .padding(10)
        }
        .onAppear() {
            recording.readInfo()
        }
    }
}

#Preview {
    RecordingInfoView(recording: Recording(fileURL: URL(fileURLWithPath: "test.wav")))
}
