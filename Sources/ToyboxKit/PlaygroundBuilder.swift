import Foundation

private func metadata(version: String, platform: Platform) -> String {
    let targetPlatform = String(describing: platform).lowercased()
    return """
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <playground version='\(version)' target-platform='\(targetPlatform)'>
        <timeline fileName='timeline.xctimeline'/>
    </playground>
    """
}

private let defaultContent = """
//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"
"""

class PlaygroundBuilder {
    private let metadataFileName = "contents.xcplayground"
    private let contentsFileName = "Contents.swift"
    private let fileManager: FileManager = .default
    private let playgroundVersion = "5.0.0"
    
    enum Error: Swift.Error {
        case invalidPath(URL)
        case creationFailure
    }
    
    func build(for platform: Platform, to destination: URL, contents: String = defaultContent) throws -> URL {
        do {
            try fileManager.createDirectory(at: destination, withIntermediateDirectories: false, attributes: nil)
        } catch {
            throw Error.invalidPath(destination)
        }
        
        let metadataURL = destination.appendingPathComponent(metadataFileName)
        let metadataContent = metadata(version: playgroundVersion, platform: platform).data(using: .utf8)
        guard fileManager.createFile(atPath: metadataURL.path,
                                     contents: metadataContent,
                                     attributes: nil) else {
                                        throw Error.creationFailure
        }
        
        let contentsURL = destination.appendingPathComponent(contentsFileName)
        let content = contents.data(using: .utf8)
        guard fileManager.createFile(atPath: contentsURL.path,
                                     contents: content,
                                     attributes: nil) else {
                                        throw Error.creationFailure
        }
        
        return destination
    }
}
