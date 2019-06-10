import Foundation
import XCTest
@testable import ToyboxKit

private class TestingXcodeFinder: XcodeFinder {
    typealias Loader = TestingDataLoader
    var xcodes: [URL] = []
    let dataLoader = TestingDataLoader()
    
    init(_ xcodes: [String]) {
        self.xcodes = xcodes.map { URL(fileURLWithPath: "/Applications").appendingPathComponent("Xcode-\($0).app") }
    }
    
    func findXcodes() -> [URL] {
        return xcodes
    }
}

private class TestingDataLoader: DataLoader {
    var data: Data?
    
    init() {
        self.data = nil
    }
    
    func load(from path: URL) throws -> Data {
        return data!
    }
}

func makeData(versionString: String) -> Data {
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

final class XcodeFinderTests: XCTestCase {
    func testMajorVersion() {
        let finder = TestingXcodeFinder(["11"])
        finder.dataLoader.data = makeData(versionString: "11.0")
        let xcodePath = finder.find("11")
        XCTAssertEqual(xcodePath?.path, "/Applications/Xcode-11.app")
    }
    
    func testExactMatch() {
        let finder = TestingXcodeFinder(["10.2.1"])
        finder.dataLoader.data = makeData(versionString: "10.2.1")
        let xcodePath = finder.find("10.2.1")
        XCTAssertEqual(xcodePath?.path, "/Applications/Xcode-10.2.1.app")
    }
}
