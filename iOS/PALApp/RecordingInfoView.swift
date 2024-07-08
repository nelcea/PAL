//
//  RecordingInfoView.swift
//  PALApp
//
//  Created by Eric Bariaux on 19/06/2024.
//

import SwiftData
import SwiftUI

struct RecordingInfoView: View {
    
    @Bindable var recording: Recording
    
    @State var editing = false
   
    var body: some View {
        Group {
            if editing {
                Form {
                    TextField("name", text: $recording.name)
                    
                    TextField("comment", text: $recording.comment, axis: .vertical)
                }
            } else {
                VStack {
                    Text(recording.name)
                        .font(.title3)
                    Text("\(recording.timestamp, format: .dateTime)")
                    Text(recording.duration?.formatted() ?? "")
                    
                    Text(recording.comment)
                        .padding(.top, 20)
                    
                    Spacer()
                    
                    ShareLink(item: recording, preview: SharePreview("Share"))
                        .padding(10)
                }
            }
        }
        .padding(.top, 10)
        .onAppear() {
            recording.readInfo()
        }
        .toolbar {
            ToolbarItem {
                Button(editing ? "Save" : "Edit") {
                    withAnimation {
                        editing.toggle()
                    }
                }
            }
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Recording.self, configurations: config)
        let example = Recording(filename: "test.wav")
        return RecordingInfoView(recording: example)
            .modelContainer(container)
    } catch {
        fatalError("Failed to create model container.")
    }
}
