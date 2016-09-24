import Cocoa
import SWXMLHash
import Commandant
import Result

enum PlaygroundError: Error {
    case loadError
}

public enum Platform: String, ArgumentProtocol {
    public static func from(string: String) -> Platform? {
        return Platform(rawValue: string)
    }
    
    case iOS = "ios"
    case macOS = "macos"
    case tvOS = "tvos"
    
    public static let name: String = "platform"
}

struct Playground: CustomStringConvertible {
    let platform: Platform
    let version: String
    let name: String
    let path: URL
    
    init(platform: Platform, version: String, path: URL) {
        self.platform = platform
        self.version = version
        self.path = path
        self.name = path.deletingPathExtension().pathComponents.last ?? ""
    }
    
    static func load(from path: URL) -> Result<Playground, PlaygroundError> {
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
        if let playground = try? Playground(platform:platform,
                                        version: playgroundElement.value(ofAttribute: "version"),
                                        path: path) {
            return .success(playground)
        }
        return .failure(PlaygroundError.loadError)
    }
    
    var description: String {
        return "\(name) (\(platform))"
    }
}
