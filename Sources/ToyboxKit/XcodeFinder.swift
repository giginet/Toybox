import Foundation

private let xcodeIdentifier = "com.apple.dt.Xcode"
private let fileManager: FileManager = .default

private struct Application {
    let path: URL
    
    fileprivate struct InfoPlist: Decodable {
        let version: String
        let bundleIdentifier: String
        let xcodeVersion: Int?
        
        init?(from application: Application) {
            let parser = PlistParser()
            guard let plist = parser.parse(application.plistPath) else {
                return nil
            }
            self = plist
        }
        
        private enum CodingKeys: String, CodingKey {
            case version = "CFBundleShortVersionString"
            case bundleIdentifier = "CFBundleIdentifier"
            case xcodeVersion = "DTXcode"
        }
    }
    
    init(path: URL) {
        self.path = path
    }
    
    var plist: InfoPlist? {
        return InfoPlist(from: self)
    }
    
    var plistPath: URL {
        return path
            .appendingPathComponent("Contents")
            .appendingPathComponent("Info.plist")
    }
}

private struct PlistParser {
    func parse(_ path: URL) -> Application.InfoPlist? {
        let process = Process()
        process.launchPath = "/usr/bin/plutil"
        process.arguments = ["-p", path.path]
        if #available(OSX 10.13, *) {
            try? process.run()
        } else {
            process.launch()
        }
        process.waitUntilExit()
        guard let output = process.standardOutput as? String, let data = output.data(using: .utf8) else {
            return nil
        }
        let decoder = PropertyListDecoder()
        return try? decoder.decode(Application.InfoPlist.self, from: data)
    }
}

struct XcodeFinder {
    func find(_ version: String) -> URL? {
        guard let applicationNames = try? fileManager.contentsOfDirectory(atPath: "/Applications") else {
            return nil
        }
        let applicationPaths = applicationNames
            .filter { $0.hasSuffix(".app") }
            .map { URL(fileURLWithPath: "/Applications").appendingPathComponent($0, isDirectory: true) }
        let xcodes = applicationPaths
            .map(Application.init)
            .filter { $0.plist?.bundleIdentifier == xcodeIdentifier }
        
        if let exactMatch = xcodes.first(where: { $0.plist?.version == version }) {
            return exactMatch.path
        } else {
            let versionMap: [Int: Application] = xcodes.reduce(into: [:]) { (dict, xcode) in
                if let xcodeVersion = xcode.plist?.xcodeVersion {
                    dict[xcodeVersion] = xcode
                }
            }
            let matchingMaxVersion = xcodes
                .filter { $0.plist?.version.hasPrefix(version) ?? false }
                .compactMap { $0.plist?.xcodeVersion }
                .max()
            if let v = matchingMaxVersion {
                return versionMap[v]?.path
            }
        }
        
        return nil
    }
}
