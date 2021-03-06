import XCTest
@testable import ToyboxKit

class PlaygroundTests: XCTestCase {
    let temporaryDirectory: URL = URL(fileURLWithPath: NSTemporaryDirectory())

    var iOSTemplatePath: URL {
        let baseDir = URL(fileURLWithPath: #file).deletingLastPathComponent()
        let iOSPath = baseDir.appendingPathComponent("../../Fixtures/ios.playground")
        return iOSPath
    }

    var destinationPath: URL {
        let name = iOSTemplatePath.pathComponents.last!
        let destinationPath = temporaryDirectory.appendingPathComponent(name)
        return destinationPath
    }

    var iOSPlayground: Playground {
        let manager = FileManager.default
        if manager.fileExists(atPath: destinationPath.path) {
            try! manager.removeItem(at: destinationPath)
        }

        try! manager.copyItem(at: iOSTemplatePath, to: destinationPath)

        guard case let .success(playground) = Playground.load(from: destinationPath) else {
            fatalError()
        }
        return playground
    }

    func testLoadPlayground() {
        let playground = iOSPlayground
        XCTAssertEqual(playground.platform, .iOS)
        XCTAssertEqual(playground.version, "5.0")
        XCTAssertEqual(playground.path, destinationPath)
        XCTAssertEqual(playground.name, "ios")
    }

    func testDescription() {
        XCTAssertEqual(String(describing: iOSPlayground), "ios (iOS)")
    }

    func testReadContents() {
        let playground = iOSPlayground
        if let data = playground.contents {
            let contents = String(data: data, encoding: .utf8)
            XCTAssertEqual(contents, "var str = \"Hello, playground\"\n")
        } else {
            XCTFail("Playground content can be parsed.")
        }
    }

    func testWriteContents() {
        var playground = iOSPlayground
        playground.contents = "print(\"Hello\")".data(using: .utf8)

        if let data = playground.contents {
            let contents = String(data: data, encoding: .utf8)
            XCTAssertEqual(contents, "print(\"Hello\")")
        } else {
            XCTFail("Playground content can be wrote.")
        }
    }
}
