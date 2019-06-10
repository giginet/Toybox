import Foundation

private let fileManager: FileManager = .default

private struct Application {
    let path: URL
    
    fileprivate struct Version: Decodable {
        let version: String
        
        init?(from application: Application) {
            let decoder = PropertyListDecoder()
            do {
                let data = try Data(contentsOf: application.versionPlistPath)
                self = try decoder.decode(Application.Version.self, from: data)
            } catch {
                return nil
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case version = "CFBundleShortVersionString"
        }
    }
    
    init(path: URL) {
        self.path = path
    }
    
    var version: String? {
        return Version(from: self)?.version
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
    
    var versionPlistPath: URL {
        return path
            .appendingPathComponent("Contents")
            .appendingPathComponent("version.plist")
    }
}

private struct CommandExecutor {
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

struct XcodeFinder {
    func find(_ version: String) -> URL? {
        let executor = CommandExecutor()
        let xcodes = executor.findXcodes()
            .map(Application.init)
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
            if let v = matchingMaxVersion {
                return versionMap[v]?.path
            }
        }
        
        return nil
    }
}
