import Cocoa
import SWXMLHash
import Commandant
import Result

public enum PlaygroundError: Error {
    case loadError
}

public enum Platform: String, ArgumentProtocol {
    public static func from(string: String) -> Platform? {
        return Platform(rawValue: string.lowercased())
    }

    case iOS = "ios"
    case macOS = "macos"
    case tvOS = "tvos"

    public static let name: String = "platform"
}

public struct Playground: CustomStringConvertible {
    private let contentsFileName = "Contents.swift"
    private var contentsPath: URL {
        return path.appendingPathComponent(contentsFileName)
    }
    public let platform: Platform
    public let version: String
    public let name: String
    public let path: URL
    public var contents: Data? {
        get {
            if let data = try? Data(contentsOf: contentsPath) {
                return data
            }
            return nil
        }
        set {
            if let data = newValue {
                try? data.write(to: contentsPath)
            }
        }
    }

    public init(platform: Platform, version: String, path: URL) {
        self.platform = platform
        self.version = version
        self.path = path
        self.name = path.deletingPathExtension().pathComponents.last ?? ""
    }

    public static func load(from path: URL) -> Result<Playground, PlaygroundError> {
        let contentPath = path.appendingPathComponent("contents.xcplayground")
        guard let data = try? Data(contentsOf: contentPath) else {
            return .failure(PlaygroundError.loadError)
        }

        let content = SWXMLHash.parse(data)
        guard let playgroundElement = content["playground"].element else {
            return .failure(PlaygroundError.loadError)
        }

        guard let targetPlatform: String = playgroundElement.value(ofAttribute: "target-platform"),
            let platform: Platform = Platform(rawValue: targetPlatform) else {
                return .failure(PlaygroundError.loadError)
        }
        if let playground = try? Playground(platform: platform,
                                            version: playgroundElement.value(ofAttribute: "version"),
                                            path: path) {
            return .success(playground)
        }
        return .failure(PlaygroundError.loadError)
    }

    public var description: String {
        return "\(name) (\(platform))"
    }
}
