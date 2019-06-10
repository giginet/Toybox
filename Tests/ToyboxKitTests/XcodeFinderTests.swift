import Foundation
import XCTest
@testable import ToyboxKit

private func makeURL(from xcodeVersion: String) -> URL {
    return URL(fileURLWithPath: "/Applications")
        .appendingPathComponent("Xcode-\(xcodeVersion).app")
}

private func makePlistURL(from xcodeVersion: String) -> URL {
    return makeURL(from: xcodeVersion)
        .appendingPathComponent("Contents")
        .appendingPathComponent("version.plist")
}

func makeData(from versionString: String) -> Data {
    struct Version: Encodable {
        let version: String
        enum CodingKeys: String, CodingKey {
            case version = "CFBundleShortVersionString"
        }
    }
    
    let encoder = PropertyListEncoder()
    let version = Version(version: versionString)
    return try! encoder.encode(version)
}

private class TestingXcodeFinder: XcodeFinder {
    typealias Loader = TestingDataLoader
    var xcodes: [URL] = []
    let dataLoader = TestingDataLoader()
    
    init(_ xcodes: [String]) {
        self.xcodes = xcodes
            .map(makeURL(from:))
    }
    
    func findXcodes() -> [URL] {
        return xcodes
    }
}

private class TestingDataLoader: DataLoader {
    private var dataMap: [URL: Data] = [:]
    
    func setVersions(_ versions: [String]) {
        self.dataMap = versions.reduce(into: [:]) { $0[makePlistURL(from: $1)] = makeData(from: $1) }
    }
    
    func load(from path: URL) throws -> Data {
        return dataMap[path]!
    }
}

final class XcodeFinderTests: XCTestCase {
    func testMajorVersion() {
        let finder = TestingXcodeFinder(["11"])
        finder.dataLoader.setVersions(["11"])
        let xcodePath = finder.find("11")
        XCTAssertEqual(xcodePath?.path, "/Applications/Xcode-11.app")
    }
    
    func testExactMatch() {
        let finder = TestingXcodeFinder(["10.2.1"])
        finder.dataLoader.setVersions(["10.2.1"])
        let xcodePath = finder.find("10.2.1")
        XCTAssertEqual(xcodePath?.path, "/Applications/Xcode-10.2.1.app")
    }
    
    func testMultipleMinors() {
        let xcodes = ["10.2", "10.2.1", "10.0", "10.1"]
        let finder = TestingXcodeFinder(xcodes)
        finder.dataLoader.setVersions(xcodes)
        let xcodePath = finder.find("10")
        XCTAssertEqual(xcodePath?.path, "/Applications/Xcode-10.2.1.app")
    }
}
