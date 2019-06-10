import Foundation
import Cocoa

private func isExist(at path: URL) -> Bool {
    let manager = FileManager()
    return manager.fileExists(atPath: path.path)
}

public enum XcodeSpecifier {
    case version(String)
    case path(URL)
}

public protocol Workspace {
    static var rootURL: URL { get }
}

public protocol PlaygroundOpener {
    static func open(at path: URL, with xcode: XcodeSpecifier?) throws
}

public protocol DateProvider {
    static var date: Date { get }
}

public struct FileSystemWorkspace: Workspace {
    private static let rootDirectoryName = ".toybox"

    public static var rootURL: URL = {
        let homeDirectoryPath = URL(fileURLWithPath: NSHomeDirectory())
        return homeDirectoryPath.appendingPathComponent(FileSystemWorkspace.rootDirectoryName, isDirectory: true)
    }()
}

public struct XcodeOpener: PlaygroundOpener {
    public static func open(at path: URL, with xcode: XcodeSpecifier? = nil) throws {
        let xcodePath: URL?
        switch xcode {
        case .some(.version(let version)):
            let finder = SpotlightXcodeFinder()
            guard let foundXcode = finder.find(version) else {
                throw ToyboxError.xcodeNotFoundError(xcode)
            }
            xcodePath = foundXcode
        case .some(.path(let path)):
            guard isExist(at: path) else {
                throw ToyboxError.xcodeNotFoundError(xcode)
            }
            xcodePath = path
        case .none:
            xcodePath = nil
        }

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

public struct CurrentTimeDateProvider: DateProvider {
    public static var date: Date {
        return Date()
    }
}

public struct PlaygroundHandler<WorkspaceManager: Workspace, Provider: DateProvider, Opener: PlaygroundOpener> {
    private let playgroundBuilder = PlaygroundBuilder()

    public var rootURL: URL {
        return WorkspaceManager.rootURL
    }

    public init() {
    }

    public func bootstrap() -> Result<(), ToyboxError> {
        let manager = FileManager()
        if !manager.fileExists(atPath: WorkspaceManager.rootURL.path, isDirectory: nil) {
            do {
                try manager.createDirectory(at: WorkspaceManager.rootURL, withIntermediateDirectories: false, attributes: nil)
            } catch {
                return .failure(ToyboxError.bootstrapError)
            }
        }
        return .success(())
    }

    public func list(for platform: Platform? = nil) -> Result<[Playground], ToyboxError> {
        let filteredPlaygrounds: [Playground]
        if let platform = platform {
            filteredPlaygrounds = playgrounds.filter { $0.platform == platform }
        } else {
            filteredPlaygrounds = playgrounds
        }
        return .success(filteredPlaygrounds.sorted(by: { $0.creationDate < $1.creationDate }))
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

    @discardableResult
    public func open(_ playground: Playground, with xcode: XcodeSpecifier? = nil) -> Result<(), ToyboxError> {
        let path = playground.path
        if isExist(at: path) {
            do {
                try Opener.open(at: path, with: xcode)
            } catch {
                return .failure(ToyboxError.xcodeNotFoundError(xcode))
            }
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
            return WorkspaceManager.rootURL.appendingPathComponent("\(name).playground")
        }
    }

    private func generateDefaultFileName() -> String {
        let formatter = DateFormatter()
        let currentDate = Provider.date
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

public typealias ToyboxPlaygroundHandler = PlaygroundHandler<FileSystemWorkspace, CurrentTimeDateProvider, XcodeOpener>
