import XCTest
import Cocoa
@testable import ToyboxKit

struct TestingStorage: Workspace {
    static var rootURL: URL {
        return URL(fileURLWithPath: NSTemporaryDirectory().appending(".toybox"),
                   isDirectory: true)
    }
}

struct AssertOpener: PlaygroundOpener {
    static var opened = false

    static func open(at path: URL, with xcodePath: URL?) {
        opened = true
    }
}

struct TestingDateProvider: DateProvider {
    static var date: Date = .init(timeIntervalSinceReferenceDate: 0)
}

typealias TestingPlaygroundHandler = PlaygroundHandler<TestingStorage, TestingDateProvider, AssertOpener>

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

        _ = handler.create(.named("ios"), for: .iOS)
        _ = handler.create(.named("mac"), for: .macOS)

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
        let result = handler.create(.named("hello"), for: .iOS)
        if case .failure(_) = result {
            XCTFail("handler.list should be failed")
        }
        XCTAssertTrue(manager.fileExists(atPath: playgroundURL(for: "hello").path))
    }

    func testCreateAnonymous() {
        XCTAssertFalse(manager.fileExists(atPath: playgroundURL(for: "hello").path))
        let result = handler.create(.anonymous, for: .iOS)
        switch result {
        case .success(let playground):
            XCTAssertTrue(manager.fileExists(atPath: playgroundURL(for: playground.name).path))
            XCTAssertEqual(playground.name, "20010101090000")
        case .failure:
            XCTFail("handler.list should be failed")
        }
    }

    func testCreateWithTemporaryOption() {
        _ = handler.create(.temporary, for: .iOS)
        XCTAssertTrue(manager.fileExists(atPath: temporaryPlaygroundURL(for: "hello").path))
        XCTAssertFalse(manager.fileExists(atPath: playgroundURL(for: "hello").path))
    }

    func testListDoesNotShowTemporaryFile() {
        _ = handler.create(.named("foo"), for: .iOS)
        _ = handler.create(.temporary, for: .iOS)

        guard case let .success(list1) = handler.list() else {
            XCTFail("handler.list should be success")
            return
        }
        XCTAssertEqual(list1.count, 1)
    }

    func testOpen() {
        let result = handler.create(.named("foobar"), for: .iOS)
        switch result {
        case .success(let playground):
            _ = handler.open(playground)
        case .failure:
            XCTFail("Could not create playground")
        }
        XCTAssertTrue(AssertOpener.opened)
    }

    func testOpenTemporaryFile() {
        let result = handler.create(.temporary, for: .iOS)
        switch result {
        case .success(let playground):
            handler.open(playground)
            XCTAssertTrue(AssertOpener.opened)
        case .failure:
            XCTFail("Playground is not created")
        }
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
