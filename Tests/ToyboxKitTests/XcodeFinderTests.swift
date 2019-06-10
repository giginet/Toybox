import Foundation
import XCTest
@testable import ToyboxKit

final class XcodeFinderTests: XCTestCase {
    func testFind() {
        let finder = XcodeFinder()
        let xcodePath = finder.find("10")
        XCTAssertEqual(xcodePath?.path, "/")
    }
}
