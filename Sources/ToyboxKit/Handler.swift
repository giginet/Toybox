import Foundation
import Cocoa
import Commandant
import Result

public protocol WorkspaceType {
    static var rootURL: URL { get }
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

public struct PlaygroundHandler<Workspace: WorkspaceType, Opener: PlaygroundOpenerType> {
    private let playgroundBuilder = PlaygroundBuilder()

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

    public enum NewPlaygroundKind {
        case named(String)
        case anonymous
        case temporary
    }

    public func create(_ kind: NewPlaygroundKind, for platform: Platform, force: Bool = false) -> Result<Playground, ToyboxError> {
        let baseName: String
        let shouldSave: Bool
        switch kind {
        case .named(let name):
            baseName = name
            shouldSave = true
        case .anonymous:
            baseName = generateDefaultFileName()
            shouldSave = true
        case .temporary:
            baseName = generateDefaultFileName()
            shouldSave = false
        }
        let targetPath = fullPath(from: baseName, temporary: !shouldSave)

        if isExist(at: targetPath) {
            do {
                if force || !shouldSave {
                    let manager = FileManager()
                    try manager.removeItem(at: targetPath)
                } else {
                    return .failure(ToyboxError.duplicatedError(baseName))
                }
            } catch {
                return .failure(ToyboxError.createError(baseName))
            }
        }
        let playgroundURL: URL
        do {
            playgroundURL = try playgroundBuilder.build(for: platform, to: targetPath)
        } catch {
            return .failure(ToyboxError.createError(baseName))
        }
        guard case let .success(playground) = Playground.load(from: playgroundURL) else {
            return .failure(ToyboxError.createError(baseName))
        }
        return .success(playground)
    }

    public func open(_ playground: Playground, with xcodePath: URL? = nil) -> Result<(), ToyboxError> {
        let path = playground.path
        if isExist(at: path) {
            Opener.open(at: path, with: xcodePath)
        } else {
            return .failure(ToyboxError.openError(playground.name))
        }
        return .success(())
    }
    
    public func playground(for name: String) -> Playground? {
        return playgrounds.first { $0.name == name }
    }

    private func fullPath(from name: String, temporary: Bool = false) -> URL {
        if temporary {
            return temporaryDirectory.appendingPathComponent("\(name).playground")
        } else {
            return Workspace.rootURL.appendingPathComponent("\(name).playground")
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

public typealias ToyboxPlaygroundHandler = PlaygroundHandler<FileSystemWorkspace, XcodeOpener>
