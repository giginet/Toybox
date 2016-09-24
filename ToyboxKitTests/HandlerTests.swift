import XCTest
import Cocoa
@testable import ToyboxKit

struct TestingStorage: WorkspaceType {
    static var rootURL: URL {
        return URL(fileURLWithPath: NSTemporaryDirectory().appending(".toybox"),
                   isDirectory: true)
    }
}

struct DummyOpener: PlaygroundOpenerType {
    static func open(at path: URL) {
    }
}

typealias TestingPlaygroundHandler = PlaygroundHandler<TestingStorage, PackagedTemplateLoader, DummyOpener>

class HandlerTests: XCTestCase {
    let handler = TestingPlaygroundHandler()
    let manager = FileManager()
    
    func playgroundFile(name: String) -> URL {
        return handler.rootURL.appendingPathComponent("\(name).playground")
    }
    
    /*func testBootstrap() {
        let workspacePath = handler.rootURL
        var isDirectory = ObjCBool(false)
        XCTAssertFalse(manager.fileExists(atPath: workspacePath.path, isDirectory: &isDirectory))
        XCTAssertFalse(isDirectory.boolValue)
        let result = handler.bootstrap()
        if case .failure(_) = result {
            XCTFail()
        }
        XCTAssertTrue(manager.fileExists(atPath: workspacePath.path, isDirectory: &isDirectory))
        XCTAssertTrue(isDirectory.boolValue)
    }*/
    
    func testList() {
        _ = handler.bootstrap()
        guard case let .success(list0) = handler.list() else {
            XCTFail()
            return
        }
        XCTAssertTrue(list0.isEmpty)
        
        _ = handler.create(name: "ios", for: .iOS)
        _ = handler.create(name: "mac", for: .macOS)
        
        guard case let .success(list1) = handler.list() else {
            XCTFail()
            return
        }
        XCTAssertEqual(list1.count, 2)
        
        guard case let .success(list2) = handler.list(for: .macOS) else {
            XCTFail()
            return
        }
        XCTAssertEqual(list2.count, 1)
    }
    
    func testCreate() {
        XCTAssertFalse(manager.fileExists(atPath: playgroundFile(name: "hello").path))
        let result = handler.create(name: "hello", for: .iOS)
        if case .failure(_) = result {
            XCTFail()
        }
        XCTAssertTrue(manager.fileExists(atPath: playgroundFile(name: "hello").path))
    }
    
    func testOpen() {
        struct AssertOpener: PlaygroundOpenerType {
            static var opened = false
            
            init() {
            }
            
            static func open(at path: URL) {
                opened = true
            }
        }
        let handler = PlaygroundHandler<TestingStorage, PackagedTemplateLoader, AssertOpener>()
        _ = handler.create(name: "foobar", for: .iOS)
        _ = handler.open(name: "foobar")
        XCTAssertTrue(AssertOpener.opened)
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
