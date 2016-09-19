import XCTest
@testable import ToyboxKit

class PlaygroundTests: XCTestCase {
    let bundle = Bundle(for: PlaygroundTests.self)
    
    func testLoadPlayground() {
        guard let iOSPathString = bundle.path(forResource: "ios",
                                              ofType: "playground",
                                              inDirectory: "fixtures") else {
            XCTFail()
            return
        }
        let iOSPath = URL(fileURLWithPath: iOSPathString)
        guard let playground = Playground.load(from: iOSPath) else {
            XCTFail()
            return
        }
        XCTAssertEqual(playground.platform, .iOS)
        XCTAssertEqual(playground.version, "5.0")
    }
}
