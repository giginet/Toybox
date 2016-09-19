import Foundation
import Cocoa
import Commandant

public class BundleWrapper {
    public static var bundle: Bundle {
        return Bundle(for: BundleWrapper.self)
    }
}

public enum Platform: String, ArgumentType {
    public static func from(string: String) -> Platform? {
        return Platform(rawValue: string)
    }

    case iOS = "ios"
    case macOS = "macos"
    case tvOS = "tvos"
    
    public static let name: String = "platform"
}

public protocol StorageType {
    static var rootURL: URL { get }
    static var bundle: Bundle { get }
}

public struct FileSystemStorage: StorageType {
    private static let rootDirectoryName = ".toybox"
    
    public static var rootURL: URL = {
        let homeDirectoryPath = URL(fileURLWithPath: NSHomeDirectory())
        return homeDirectoryPath.appendingPathComponent(FileSystemStorage.rootDirectoryName, isDirectory: true)
    }()
    
    public static var bundle: Bundle {
        return BundleWrapper.bundle
    }
}

public struct PlaygroundHandler<Storage: StorageType> {
    public var rootURL: URL {
        return Storage.rootURL
    }
    
    public init() {
    }
    
    public func bootstrap() throws {
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
    
    private func isExist(at path: URL) -> Bool {
        let manager = FileManager()
        return manager.fileExists(atPath: path.path)
    }
    
    private func generateDefaultFileName() -> String {
        let formatter = DateFormatter()
        let currentDate = Date()
        formatter.dateFormat = "yyyyMMddHHmmss"
        return formatter.string(from: currentDate)
    }
    
    private var playgrounds: [Playground] {
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: rootURL.path)
            let playgroundPathes = files.filter { $0.hasSuffix("playground") }.map { rootURL.appendingPathComponent($0) }
            let playgrounds: [Playground] = playgroundPathes.flatMap { try? Playground.load(from: $0) }
            return playgrounds
        } catch {
            return []
        }
    }
    
    public func list(for platform: Platform?) throws -> [String] {
        let filteredPlaygrounds: [Playground]
        if let platform = platform {
            filteredPlaygrounds = playgrounds.filter { $0.platform == platform }
        } else {
            filteredPlaygrounds = playgrounds
        }
        return filteredPlaygrounds.map { String(describing: $0) }
    }
    
    public func create(name: String?, for platform: Platform) throws {
        let baseName: String = name ?? generateDefaultFileName()
        
        _ = try copyTemplate(of: platform, for: "\(baseName).playground")
        try open(name: baseName)
    }
    
    public func open(name: String) throws {
        let path = fullPath(from: name)
        if isExist(at: path) {
            let workspace = NSWorkspace.shared()
            workspace.open(path)
        } else {
            throw ToyboxError.openError
        }
    }
}
