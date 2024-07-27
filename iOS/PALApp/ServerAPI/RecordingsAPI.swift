//
//  RecordingsAPI.swift
//  PALApp
//
//  Created by Eric Bariaux on 19/07/2024.
//

import Foundation

struct RecordingsAPI {
    var serverName = "http://localhost:8080"
    
    func doesRecordingExistOnServer(recording: Recording) async throws -> Bool {
        guard var urlComponents = URLComponents(string: "http://\(serverName)") else {
            print("Invalid base URL")
            throw RecordingAPIError.generic
        }
        urlComponents.path.append("/recordings")
        urlComponents.path.append("/\(recording.id)")
        
        guard let url = urlComponents.url else {
            print("Invalid url")
            throw RecordingAPIError.generic
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        // Should do a get before post (or use option, or can I use ETag or something like that ?)
        print("requesting...")
        let (data, response) = try await URLSession.shared.data (for: urlRequest)
        print(response)
        guard let httpResponse = response as? HTTPURLResponse else {
            print("Error")
            throw RecordingAPIError.generic
        }
        
        switch httpResponse.statusCode {
        case 200:
            return true
        case 404:
            return false
        default:
            print("Error")
            throw RecordingAPIError.generic
        }
    }
   
    func pushRecording(recording: Recording) async throws {
        guard var urlComponents = URLComponents(string: "http://\(serverName)") else {
            print("Invalid base URL")
            return
        }
        urlComponents.path.append("/recordings")
        urlComponents.path.append("/\(recording.id)")
        guard let url = urlComponents.url else {
            print("Invalid url")
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        urlRequest.httpBody = try encoder.encode(recording.toDTO())
        
        // Should do a get before post (or use option, or can I use ETag or something like that ?)
        print("pushing...")
        let (data, response) = try await URLSession.shared.data (for: urlRequest)
        print(response)
        print(String(data: data, encoding: .utf8))
    }

    func doesAudioExistOnServer(recording: Recording) async throws -> Bool {
        guard var urlComponents = URLComponents(string: "http://\(serverName)") else {
            print("Invalid base URL")
            throw RecordingAPIError.generic
        }
        let queryByFilename = URLQueryItem(name: "filename", value: recording.filename)
        
        urlComponents.path.append("/recordings")
        urlComponents.path.append("/\(recording.id)")
        urlComponents.path.append("/audio")

        guard let url = urlComponents.url else {
            print("Invalid url")
            throw RecordingAPIError.generic
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "HEAD"

        print("checking audio...")
        let (data, response) = try await URLSession.shared.data (for: urlRequest)
        print(response)
        print(String(data: data, encoding: .utf8))

        guard let httpResponse = response as? HTTPURLResponse else {
            print("Error")
            throw RecordingAPIError.generic
        }
        
        switch httpResponse.statusCode {
        case 200:
            return true
        case 404:
            return false
        default:
            print("Error")
            throw RecordingAPIError.generic
        }
    }

    func pushAudio(recording: Recording) async throws {
        guard var urlComponents = URLComponents(string: "http://\(serverName)") else {
            print("Invalid base URL")
            return
        }
        urlComponents.path.append("/recordings")
        urlComponents.path.append("/\(recording.id)")
        urlComponents.path.append("/audio")
        guard let url = urlComponents.url else {
            print("Invalid url")
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("audio/wav", forHTTPHeaderField: "Content-Type")
        
        // TODO: stream insteaf of loading all in memory (check it does load in memory)
        urlRequest.httpBody = try Data(contentsOf: recording.fileURL)
        
        // Should do a get before post (or use option, or can I use ETag or something like that ?)
        print("pushing audio...")
        let (data, response) = try await URLSession.shared.data (for: urlRequest)
        print(response)
        print(String(data: data, encoding: .utf8))
    }
}

enum RecordingAPIError: Error {
    case generic
}

