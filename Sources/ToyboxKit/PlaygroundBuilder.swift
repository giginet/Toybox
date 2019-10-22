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
private let defaultContentForMac = """
//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"
"""

private func defaultContent(for platform: Platform) -> Data {
    let content: String
    switch platform {
    case .iOS, .tvOS:
        content = defaultContent
    case .macOS:
        content = defaultContentForMac
    }
    return content.data(using: .utf8)!
}

class PlaygroundBuilder {
    private let metadataFileName = "contents.xcplayground"
    private let contentsFileName = "Contents.swift"
    private let fileManager: FileManager = .default
    private let playgroundVersion = "5.0.0"

    enum Error: Swift.Error {
        case invalidPath(URL)
        case creationFailure
    }

    func build(for platform: Platform, to destination: URL) throws -> URL {
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
        let contentData = defaultContent(for: platform)
        guard fileManager.createFile(atPath: contentsURL.path,
                                     contents: contentData,
                                     attributes: nil) else {
                                        throw Error.creationFailure
        }

        return destination
    }
}
