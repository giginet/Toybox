import Foundation
import Cocoa
import Commandant
import Result

internal class BundleWrapper {
    public static var bundle: Bundle {
        return Bundle(for: BundleWrapper.self)
    }
}

public protocol WorkspaceType {
    static var rootURL: URL { get }
}

public protocol TemplateLoaderType {
    static func templatePath(of platform: Platform) -> URL
}

public protocol PlaygroundOpenerType {
    static func open(at path: URL)
}

public struct FileSystemWorkspace: WorkspaceType {
    private static let rootDirectoryName = ".toybox"
    
    public static var rootURL: URL = {
        let homeDirectoryPath = URL(fileURLWithPath: NSHomeDirectory())
        return homeDirectoryPath.appendingPathComponent(FileSystemWorkspace.rootDirectoryName, isDirectory: true)
    }()
}

public struct PackagedTemplateLoader: TemplateLoaderType {
    public static let bundle = BundleWrapper.bundle
    
    public static func templatePath(of platform: Platform) -> URL {
        guard let resourceURL = bundle.resourceURL else {
            fatalError("Loading template is failure")
        }
        return resourceURL.appendingPathComponent("Templates/\(platform.rawValue).playground")
    }
}

public struct XcodeOpener: PlaygroundOpenerType {
    public static func open(at path: URL) {
        let workspace = NSWorkspace.shared()
        workspace.open(path)
    }
}

public struct PlaygroundHandler<Workspace: WorkspaceType, Loader: TemplateLoaderType, Opener: PlaygroundOpenerType> {
    public var rootURL: URL {
        return Workspace.rootURL
    }
    
    public init() {
    }
    
    public func bootstrap() -> Result<(), ToyboxError> {
        let manager = FileManager()
        if !manager.fileExists(atPath: Workspace.rootURL.path, isDirectory: nil) {
            do {
                try manager.createDirectory(at: Workspace.rootURL, withIntermediateDirectories: false, attributes: nil)
            } catch {
                return .failure(ToyboxError.bootstrapError)
            }
        }
        return .success()
    }
    
    private func fullPath(from name: String) -> URL {
        return Workspace.rootURL.appendingPathComponent("\(name).playground")
    }
    
    private func templatePath(of platform: Platform) -> URL {
        return Loader.templatePath(of: platform)
    }
    
    private func copyTemplate(of platform: Platform, for name: String) -> Result<URL, ToyboxError> {
        let destinationPath = Workspace.rootURL.appendingPathComponent(name)
        let sourcePath = templatePath(of: platform)
        let manager = FileManager()
        do {
            try manager.copyItem(at: sourcePath, to: destinationPath)
            return .success(destinationPath)
        } catch {
            return .failure(ToyboxError.createError(name))
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
            let playgrounds: [Playground] = playgroundPathes.flatMap { path in
                switch Playground.load(from: path) {
                case let .success(playground):
                    return playground
                case .failure:
                    return nil
                }
            }
            return playgrounds
        } catch {
            return []
        }
    }
    
    public func list(for platform: Platform?) -> Result<[String], ToyboxError> {
        let filteredPlaygrounds: [Playground]
        if let platform = platform {
            filteredPlaygrounds = playgrounds.filter { $0.platform == platform }
        } else {
            filteredPlaygrounds = playgrounds
        }
        return .success(filteredPlaygrounds.map { String(describing: $0) })
    }
    
    public func create(name: String?, for platform: Platform, force: Bool = false) -> Result<(), ToyboxError> {
        let baseName: String = name ?? generateDefaultFileName()
        let targetPath = fullPath(from: baseName)
        
        if isExist(at: targetPath) {
            do {
                if force {
                    let manager = FileManager()
                    try manager.removeItem(at: targetPath)
                } else {
                    return .failure(ToyboxError.duplicatedError(baseName))
                }
            } catch {
                return .failure(ToyboxError.createError(baseName))
            }
        }
        _ = try copyTemplate(of: platform, for: "\(baseName).playground")
        try open(name: baseName)
        return .success()
    }
    
    public func open(name: String) -> Result<(), ToyboxError> {
        let path = fullPath(from: name)
        if isExist(at: path) {
            Opener.open(at: path)
        } else {
            return .failure(ToyboxError.openError(name))
        }
        return .success()
    }
}

public typealias ToyboxPlaygroundHandler = PlaygroundHandler<FileSystemWorkspace, PackagedTemplateLoader, XcodeOpener>
