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
    static var bundle: Bundle { get }
}

class Piyo {
}

struct FileSystemStorage: StorageType {
    static let rootDirectoryName = ".toybox"
    
    static var rootURL: URL = {
        let homeDirectoryPath = URL(fileURLWithPath: NSHomeDirectory())
        return homeDirectoryPath.appendingPathComponent(FileSystemStorage.rootDirectoryName, isDirectory: true)
    }()
    
    static var bundle: Bundle {
        return Bundle(for: Piyo.self)
    }
}

struct PlaygroundHandler<Storage: StorageType> {
    var rootURL: URL {
        return Storage.rootURL
    }
    
    func bootstrap() throws {
        let manager = FileManager()
        if !manager.fileExists(atPath: Storage.rootURL.path, isDirectory: nil) {
            do {
                try manager.createDirectory(at: Storage.rootURL, withIntermediateDirectories: false, attributes: nil)
            } catch {
                throw ToyboxError.bootstrapError
            }
        }
    }
    
    private func fullPath(from name: String) -> URL {
        return Storage.rootURL.appendingPathComponent("\(name).playground")
    }
    
    private func templatePath(of platform: Platform) -> URL {
        guard let resourceURL = Storage.bundle.resourceURL else {
            fatalError("Templates are not found")
        }
        return resourceURL.appendingPathComponent("Templates/\(platform.rawValue).playground")
    }
    
    private func copyTemplate(of platform: Platform, for name: String) throws -> URL {
        let destinationPath = Storage.rootURL.appendingPathComponent(name)
        let sourcePath = templatePath(of: platform)
        let manager = FileManager()
        do {
            try manager.copyItem(at: sourcePath, to: destinationPath)
            return destinationPath
        } catch {
            throw ToyboxError.createError
        }
    }
    
    func isExist(at path: URL) -> Bool {
        let manager = FileManager()
        return manager.fileExists(atPath: path.path)
    }
    
    private func generateDefaultFileName() -> String {
        let formatter = DateFormatter()
        let currentDate = Date()
        formatter.dateFormat = "yyyyMMddHHmmss"
        return formatter.string(from: currentDate)
    }
    
    func list(for platform: Platform?) throws -> [String] {
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: rootURL.path)
            let playgrounds = files.filter { $0.hasSuffix("playground") }
            return playgrounds
        } catch {
            throw ToyboxError.listError
        }
    }
    
    func create(name: String?, for platform: Platform) throws {
        let baseName: String = name ?? generateDefaultFileName()
        
        let destinationPath = try copyTemplate(of: platform, for: "\(baseName).playground")
        try open(name: baseName)
    }
    
    func open(name: String) throws {
        let path = fullPath(from: name)
        if isExist(at: path) {
            let workspace = NSWorkspace.shared()
            workspace.open(path)
        } else {
            throw ToyboxError.openError
        }
    }
}
