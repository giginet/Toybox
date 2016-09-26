import XCTest
@testable import ToyboxKit

class PlaygroundTests: XCTestCase {
    let bundle = Bundle(for: PlaygroundTests.self)
    let temporaryDirectory: URL = URL(fileURLWithPath: NSTemporaryDirectory())
    
    var iOSTemplatePath: URL {
        guard let iOSPathString = bundle.path(forResource: "ios",
                                              ofType: "playground",
                                              inDirectory: "fixtures") else {
                                                fatalError()
        }
        let iOSPath = URL(fileURLWithPath: iOSPathString)
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
    
    func testContents() {
        let playground = iOSPlayground
        if let data = playground.contents {
            let contents = String(data: data, encoding: .utf8)
            XCTAssertEqual(contents, "var str = \"Hello, playground\"")
        } else {
            XCTFail()
        }
    }
}
