import XCTest
import Cocoa
@testable import ToyboxKit

struct TestingStorage: WorkspaceType {
    static var rootURL: URL {
        return URL(fileURLWithPath: NSTemporaryDirectory(),
                   isDirectory: true)
    }
}

struct TemplateLoader: TemplateLoaderType {
    static func templatePath(of platform: Platform) -> URL {
        let pathString = BundleWrapper.bundle.path(forResource: platform.rawValue,
                                                   ofType: "playground",
                                                   inDirectory: "Templates")!
        return URL(fileURLWithPath: pathString)
    }
}

struct DummyOpener: PlaygroundOpenerType {
    static func open(at path: URL) {
    }
}

typealias TestingPlaygroundHandler = PlaygroundHandler<TestingStorage, TemplateLoader, DummyOpener>

class PlaygroundHandlerTests: XCTestCase {
    let handler = TestingPlaygroundHandler()
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
