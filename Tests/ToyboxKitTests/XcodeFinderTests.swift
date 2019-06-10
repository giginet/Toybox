import Foundation
import XCTest
@testable import ToyboxKit

final class XcodeFinderTests: XCTestCase {
    func testMajorVersion() {
        let finder = XcodeFinder()
        let xcodePath = finder.find("11")
        XCTAssertEqual(xcodePath?.path, "/Applications/Xcode-11.app")
    }
    
    func testExactMatch() {
        let finder = XcodeFinder()
        let xcodePath = finder.find("10.2.1")
        XCTAssertEqual(xcodePath?.path, "/Applications/Xcode-10.2.app")
    }
}
