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
    static func open(at path: URL, with xcodePath: URL?)
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
    public static func open(at path: URL, with xcodePath: URL? = nil) {
        if let xcodePath = xcodePath {
            let workspace = NSWorkspace.shared
            _ = try? workspace.open([path],
                                    withApplicationAt: xcodePath,
                                    options: [],
                                    configuration: [:])
        } else {
            let workspace = NSWorkspace.shared
            workspace.open(path)
        }
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
        return .success(())
    }

    public func list(for platform: Platform? = nil) -> Result<[String], ToyboxError> {
        let filteredPlaygrounds: [Playground]
        if let platform = platform {
            filteredPlaygrounds = playgrounds.filter { $0.platform == platform }
        } else {
            filteredPlaygrounds = playgrounds
        }
        return .success(filteredPlaygrounds.map { String(describing: $0) })
    }

    public func create(_ name: String?, for platform: Platform, force: Bool = false, temporary: Bool = false) -> Result<Playground, ToyboxError> {
        let baseName: String = name ?? generateDefaultFileName()
        let targetPath = fullPath(from: baseName, temporary: temporary)

        if isExist(at: targetPath) {
            do {
                if force || temporary {
                    let manager = FileManager()
                    try manager.removeItem(at: targetPath)
                } else {
                    return .failure(ToyboxError.duplicatedError(baseName))
                }
            } catch {
                return .failure(ToyboxError.createError(baseName))
            }
        }
        guard case let .success(createdURL) = copyTemplate(of: platform, for: baseName, temporary: temporary) else {
            return .failure(ToyboxError.createError(baseName))
        }
        guard case let .success(playground) = Playground.load(from: createdURL) else {
            return .failure(ToyboxError.createError(baseName))
        }
        return .success(playground)
    }

    public func open(_ name: String, with xcodePath: URL? = nil, temporary: Bool = false) -> Result<(), ToyboxError> {
        let path = fullPath(from: name, temporary: temporary)
        if isExist(at: path) {
            Opener.open(at: path, with: xcodePath)
        } else {
            return .failure(ToyboxError.openError(name))
        }
        return .success(())
    }

    private func fullPath(from name: String, temporary: Bool = false) -> URL {
        if temporary {
            return temporaryDirectory.appendingPathComponent("\(name).playground")
        } else {
            return Workspace.rootURL.appendingPathComponent("\(name).playground")
        }
    }

    private func templatePath(of platform: Platform) -> URL {
        return Loader.templatePath(of: platform)
    }

    private func copyTemplate(of platform: Platform, for name: String, temporary: Bool = false) -> Result<URL, ToyboxError> {
        let destinationPath = fullPath(from: name, temporary: temporary)
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
            let playgrounds: [Playground] = playgroundPathes.compactMap { path in
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

    private var temporaryDirectory: URL {
        if #available(OSX 10.12, *) {
            return FileManager.default.temporaryDirectory
        } else {
            return URL(fileURLWithPath: NSTemporaryDirectory())
        }
    }
}

public typealias ToyboxPlaygroundHandler = PlaygroundHandler<FileSystemWorkspace, PackagedTemplateLoader, XcodeOpener>
