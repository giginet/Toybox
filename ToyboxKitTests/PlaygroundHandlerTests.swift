import XCTest
import Cocoa
@testable import ToyboxKit

struct TestingStorage: StorageType {
    static var rootURL: URL {
        return URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
    }
    
    static var bundle: Bundle {
        return BundleWrapper.bundle
    }
}

class PlaygroundHandlerTests: XCTestCase {
    let handler = PlaygroundHandler<TestingStorage>()
    let manager = FileManager()
    
    func playgroundFile(name: String) -> URL {
        return handler.rootURL.appendingPathComponent("\(name).playground")
    }
    
    func testCreate() {
        XCTAssertFalse(manager.fileExists(atPath: playgroundFile(name: "hello").path))
        try! handler.create(name: "hello", for: .iOS)
        XCTAssertTrue(manager.fileExists(atPath: playgroundFile(name: "hello").path))
    }
    
    override func tearDown() {
        super.tearDown()
        
        let enumerator = manager.enumerator(at: TestingStorage.rootURL,
                           includingPropertiesForKeys: nil,
                           options: [],
                           errorHandler: nil)!
        for case let filepath as URL in enumerator {
            try? manager.removeItem(at: filepath)
        }
    }
    
}
