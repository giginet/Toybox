import Cocoa
import SWXMLHash

enum PlaygroundError: Error {
    case deserializeError
}

struct Playground: XMLIndexerDeserializable {
    let platform: Platform
    let version: String
    
    static func deserialize(_ node: XMLIndexer) throws -> Playground {
        guard let platform = try Platform(rawValue: node.value(ofAttribute: "target-platform")) else {
            throw PlaygroundError.deserializeError
        }
        
        return try Playground(
            platform: platform,
            version: node.value(ofAttribute: "version")
        )
    }
    
    static func load(from path: URL) -> Playground? {
        guard let data = try? Data(contentsOf: path) else {
            return nil
        }
        
        let content = SWXMLHash.parse(data)
        guard let playground: Playground = try? content["playground"].value() else {
            return nil
        }
        return playground
    }
}
