import XCTest
@testable import ToyboxKit

class PlaygroundTests: XCTestCase {
    let bundle = Bundle(for: PlaygroundTests.self)
    
    var iOSPlayground: Playground {
        guard let iOSPathString = bundle.path(forResource: "ios",
                                              ofType: "playground",
                                              inDirectory: "fixtures") else {
                                                fatalError()
        }
        let iOSPath = URL(fileURLWithPath: iOSPathString)
        guard let playground = try? Playground.load(from: iOSPath) else {
            fatalError()
        }
        return playground
    }
    
    func testLoadPlayground() {
        guard let iOSPathString = bundle.path(forResource: "ios",
                                              ofType: "playground",
                                              inDirectory: "fixtures") else {
                                                fatalError()
        }
        let iOSPath = URL(fileURLWithPath: iOSPathString)
        
        let playground = iOSPlayground
        XCTAssertEqual(playground.platform, .iOS)
        XCTAssertEqual(playground.version, "5.0")
        XCTAssertEqual(playground.path, iOSPath)
        XCTAssertEqual(playground.name, "ios")
    }
    
    func testDescription() {
        XCTAssertEqual(String(describing: iOSPlayground), "ios (iOS)")
    }
}
