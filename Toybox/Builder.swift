import Foundation
import Cocoa
import Commandant

enum Platform: String, ArgumentType {
    case iOS = "ios"
    case macOS = "macos"
    case tvOS = "tvos"
    
    static let name: String = "platform"
    
    /// Attempts to parse a value from the given command-line argument.
    static func fromString(_ string: String) -> Platform? {
        return Platform(rawValue: string)
    }
}

protocol StorageType {
    static var rootURL: URL { get }
    static func bootstrap() throws
    static func copy(at sourcePath: URL, for name: String) -> URL
    static func templatePath(of platform: Platform, bundle: Bundle) -> URL
    static func open(at path: URL)
}

enum BuilderError: Error {
    case bootstrapError
}

struct FileSystemStorage: StorageType {
    static let rootDirectoryName = ".toybox"
    
    static var rootURL: URL = {
        let homeDirectoryPath = URL(fileURLWithPath: NSHomeDirectory())
        return homeDirectoryPath.appendingPathComponent(FileSystemStorage.rootDirectoryName, isDirectory: true)
    }()
    
    static func bootstrap() throws {
        let manager = FileManager()
        if !manager.fileExists(atPath: rootURL.absoluteString, isDirectory: nil) {
            do {
                try manager.createDirectory(at: rootURL, withIntermediateDirectories: false, attributes: nil)
            } catch {
                throw BuilderError.bootstrapError
            }
        }
    }

    static func copy(at sourcePath: URL, for name: String) -> URL {
        let destinationPath = rootURL.appendingPathComponent(name)
        let manager = FileManager()
        do {
            try manager.copyItem(at: sourcePath, to: destinationPath)
            return destinationPath
        } catch {
            fatalError("Could not copy templates")
        }
    }
    
    static func templatePath(of platform: Platform, bundle: Bundle) -> URL {
        guard let resourceURL = bundle.resourceURL else {
            fatalError("Templates are not found")
        }
        return resourceURL.appendingPathComponent("Templates/\(platform.rawValue).playground")
    }
    
    static func open(at path: URL) {
        let workspace = NSWorkspace.shared()
        workspace.open(path)
    }
}

struct PlaygroundBuilder<Storage: StorageType> {
    let bundle: Bundle
    
    init(bundle: Bundle) {
        self.bundle = bundle
    }
    
    func bootstrap() throws {
        try Storage.bootstrap()
    }
    
    func defaultFileName() -> String {
        let formatter = DateFormatter()
        let currentDate = Date()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: currentDate)
    }
    
    func create(name: String, for platform: Platform) {
        let source = Storage.templatePath(of: platform, bundle: bundle)
        let destinationPath = Storage.copy(at: source, for: "\(name).playground")
        Storage.open(at: destinationPath)
    }
}
