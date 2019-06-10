import Foundation

struct Application {
    let path: URL
    let versionContainer: Version?

    struct Version: Decodable {
        let version: String

        init?(from versionPlistPath: URL, dataLoader: DataLoader) {
            let decoder = PropertyListDecoder()
            do {
                let data = try dataLoader.load(from: versionPlistPath)
                self = try decoder.decode(Application.Version.self, from: data)
            } catch {
                return nil
            }
        }

        private enum CodingKeys: String, CodingKey {
            case version = "CFBundleShortVersionString"
        }
    }

    init(path: URL, dataLoader: DataLoader) {
        self.path = path
        let versionPlistPath = path
            .appendingPathComponent("Contents")
            .appendingPathComponent("version.plist")
        self.versionContainer = Version(from: versionPlistPath, dataLoader: dataLoader)
    }

    var version: String? {
        return versionContainer?.version
    }

    /// Covert version to sortable version
    /// 10.2 -> 102
    var versionCode: Int? {
        return version?
            .split(separator: ".")
            .map(String.init)
            .compactMap(Int.init)
            .reversed()
            .enumerated()
            .reduce(into: 0) { ( defaultValue: inout Int, element: (Int, Int)) in
                return defaultValue += Int(pow(10.0, Double(element.0))) * element.1
        }
    }
}

protocol DataLoader {
    func load(from path: URL) throws -> Data
}

protocol XcodeFinder {
    associatedtype Loader: DataLoader
    var dataLoader: Loader { get }
    func findXcodes() -> [URL]
}

extension XcodeFinder {
    func find(_ version: String) -> URL? {
        let xcodes = findXcodes()
            .map { Application(path: $0, dataLoader: dataLoader) }
        if let exactMatch = xcodes.first(where: { $0.version == version }) {
            return exactMatch.path
        } else {
            let versionMap: [Int: Application] = xcodes.reduce(into: [:]) { (dict, xcode) in
                if let versionCode = xcode.versionCode {
                    dict[versionCode] = xcode
                }
            }
            let matchingMaxVersion = xcodes
                .filter { $0.version?.hasPrefix(version) ?? false }
                .compactMap { $0.versionCode }
                .max()
            if let matchingVersion = matchingMaxVersion {
                return versionMap[matchingVersion]?.path
            }
        }

        return nil
    }
}

struct FileSystemDataLoader: DataLoader {
    func load(from path: URL) throws -> Data {
        return try Data(contentsOf: path)
    }
}

struct SpotlightXcodeFinder: XcodeFinder {
    typealias Loader = FileSystemDataLoader
    let dataLoader: FileSystemDataLoader = FileSystemDataLoader()

    func findXcodes() -> [URL] {
        let process = Process()
        process.launchPath = "/usr/bin/mdfind"
        process.arguments = ["kMDItemCFBundleIdentifier == 'com.apple.dt.Xcode'"]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.launch()

        let readHandle = pipe.fileHandleForReading
        let data = readHandle.readDataToEndOfFile()

        guard let output = String(data: data, encoding: .utf8) else {
            return []
        }

        return output
            .split(separator: "\n")
            .map { URL.init(fileURLWithPath: String($0)) }
    }
}
