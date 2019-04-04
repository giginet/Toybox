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

    public var displayName: String {
        switch self {
        case .iOS: return "iOS"
        case .macOS: return "macOS"
        case .tvOS: return "tvOS"
        }
    }

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
    public let creationDate: Date
    public var contentLength: Int? {
        guard let data = contents else {
            return nil
        }
        return String(data: data, encoding: .utf8)?.split(separator: "\n").count
    }

    private init(platform: Platform, version: String, path: URL, creationDate: Date) {
        self.platform = platform
        self.version = version
        self.path = path
        self.name = path.deletingPathExtension().pathComponents.last ?? ""
        self.creationDate = creationDate
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
        let cretionDate = try! FileManager.default.attributesOfItem(atPath: path.path)[.creationDate] as? Date
        if let playground = try? Playground(platform: platform,
                                            version: playgroundElement.value(ofAttribute: "version"),
                                            path: path,
                                            creationDate: cretionDate!) {
            return .success(playground)
        }
        return .failure(PlaygroundError.loadError)
    }

    public var description: String {
        return "\(name) \(platform.displayName))"
    }
}
