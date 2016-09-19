import Cocoa
import SWXMLHash

enum PlaygroundError: Error {
    case loadError
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
    
    static func load(from path: URL) throws -> Playground {
        let contentPath = path.appendingPathComponent("contents.xcplayground")
        guard let data = try? Data(contentsOf: contentPath) else {
            throw PlaygroundError.loadError
        }
        
        let content = SWXMLHash.parse(data)
        guard let playgroundElement = content["playground"].element else {
            throw PlaygroundError.loadError
        }
        
        guard let platform = try Platform(rawValue: playgroundElement.value(ofAttribute: "target-platform")) else {
            throw PlaygroundError.loadError
        }
        let playground = try Playground(platform: platform,
                                        version: playgroundElement.value(ofAttribute: "version"),
                                        path: path)
        return playground
    }
    
    var description: String {
        return "\(name) (\(platform))"
    }
}
