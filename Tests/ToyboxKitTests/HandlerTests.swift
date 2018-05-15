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
    static func open(at path: URL, with xcodePath: URL?) {
    }
}

typealias TestingPlaygroundHandler = PlaygroundHandler<TestingStorage, PackagedTemplateLoader, DummyOpener>

class HandlerTests: XCTestCase {
    let handler = TestingPlaygroundHandler()
    let manager = FileManager()

    override func setUp() {
        super.setUp()

        _ = handler.bootstrap()
    }

    func playgroundURL(for name: String) -> URL {
        return handler.rootURL.appendingPathComponent("\(name).playground")
    }

    func temporaryPlaygroundURL(for name: String) -> URL {
        if #available(OSX 10.12, *) {
            return manager.temporaryDirectory.appendingPathComponent("\(name).playground")
        } else {
            return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(name).playground")
        }
    }

    func testList() {
        _ = handler.bootstrap()
        guard case let .success(list0) = handler.list() else {
            XCTFail("handler.list should be success")
            return
        }
        XCTAssertTrue(list0.isEmpty)

        _ = handler.create("ios", for: .iOS)
        _ = handler.create("mac", for: .macOS)

        guard case let .success(list1) = handler.list() else {
            XCTFail("handler.list should be success")
            return
        }
        XCTAssertEqual(list1.count, 2)

        guard case let .success(list2) = handler.list(for: .macOS) else {
            XCTFail("handler.list should be success")
            return
        }
        XCTAssertEqual(list2.count, 1)
    }

    func testCreate() {
        XCTAssertFalse(manager.fileExists(atPath: playgroundURL(for: "hello").path))
        let result = handler.create("hello", for: .iOS)
        if case .failure(_) = result {
            XCTFail("handler.list should be failed")
        }
        XCTAssertTrue(manager.fileExists(atPath: playgroundURL(for: "hello").path))
    }

    func testCreateWithTemporaryOption() {
        _ = handler.create("hello", for: .iOS, temporary: true)
        XCTAssertTrue(manager.fileExists(atPath: temporaryPlaygroundURL(for: "hello").path))
        XCTAssertFalse(manager.fileExists(atPath: playgroundURL(for: "hello").path))
    }

    func testListDoesNotShowTemporaryFile() {
        _ = handler.create("foo", for: .iOS)
        _ = handler.create("bar", for: .iOS, temporary: true)

        guard case let .success(list1) = handler.list() else {
            XCTFail("handler.list should be success")
            return
        }
        XCTAssertEqual(list1.count, 1)
    }

    func testOpen() {
        struct AssertOpener: PlaygroundOpenerType {
            static var opened = false

            static func open(at path: URL, with xcodePath: URL?) {
                opened = true
            }
        }
        let handler = PlaygroundHandler<TestingStorage, PackagedTemplateLoader, AssertOpener>()
        _ = handler.create("foobar", for: .iOS)
        _ = handler.open("foobar")
        XCTAssertTrue(AssertOpener.opened)
    }

    func testOpenTemporaryFile() {
        struct AssertOpener: PlaygroundOpenerType {
            static var opened = false

            static func open(at path: URL, with xcodePath: URL?) {
                opened = true
            }
        }
        let handler = PlaygroundHandler<TestingStorage, PackagedTemplateLoader, AssertOpener>()
        _ = handler.create("foobar", for: .iOS, temporary: true)
        _ = handler.open("foobar", temporary: true)
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
