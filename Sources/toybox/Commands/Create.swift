import Foundation
import ToyboxKit
import Commandant
import Result

struct CreateOptions: OptionsProtocol {
    typealias ClientError = ToyboxError
    let fileName: String?
    let platform: Platform
    let force: Bool
    let noOpen: Bool
    let store: Bool
    let enableStandardInput: Bool
    let xcodePath: URL?

    static func create(_ platform: Platform) -> (String?) -> ([String]) -> (Bool) -> (Bool) -> (Bool) -> (Bool) -> CreateOptions {
        return { xcodePathString in { fileNames in { force in { noOpen in { store in { standardInput in
            let xcodePath: URL?
            if let xcodePathString = xcodePathString {
                xcodePath = URL(fileURLWithPath: xcodePathString)
            } else {
                xcodePath = nil
            }
            return self.init(fileName: fileNames.first,
                             platform: platform,
                             force: force,
                             noOpen: noOpen,
                             store: store,
                             enableStandardInput: standardInput,
                             xcodePath: xcodePath)
            } } } } }
        }
    }

    static func evaluate(_ m: CommandMode) -> Result<CreateOptions, CommandantError<ToyboxError>> {
        return create
            <*> m <| Option(key: "platform", defaultValue: Platform.iOS, usage: "Target platform (ios/macos/tvos)")
            <*> m <| Option<String?>(key: "xcode-path", defaultValue: nil, usage: "Xcode path to open with")
            <*> m <| Argument(defaultValue: [], usage: "Playground file name to create")
            <*> m <| Switch(flag: "f", key: "force", usage: "Whether to overwrite existing playground")
            <*> m <| Switch(flag: "s", key: "store", usage: "Whether to save to workspace as anonymous playground")
            <*> m <| Switch(key: "no-open", usage: "Whether to open new playground")
            <*> m <| Switch(key: "input", usage: "Whether to enable standard input")
    }
}

struct CreateCommand: CommandProtocol {
    typealias Options = CreateOptions
    typealias ClientError = ToyboxError

    let verb = "create"
    let function = "Create new Playground"

    func run(_ options: Options) -> Result<(), ToyboxError> {
        let handler = ToyboxPlaygroundHandler()
        if case let .failure(error) = handler.bootstrap() {
            return .failure(error)
        }

        let shouldStore = options.store || (options.fileName == nil)
        let kind: ToyboxPlaygroundHandler.NewPlaygroundKind
        switch (options.store, options.fileName) {
        case (false, .some(let fileName)):
            kind = .named(fileName)
        case (true, .some(let fileName)):
            kind = .named(fileName)
        case (false, .none):
            kind = .temporary
        case (true, .none):
            kind = .anonymous
        }

        switch handler.create(kind, for: options.platform, force: options.force) {
        case let .success(playground):
            if options.enableStandardInput {
                let data = FileHandle.standardInput.readDataToEndOfFile()
                if data.count > 0 {
                    var mutablePlayground = playground
                    mutablePlayground.contents = data
                }
            }

            if !options.noOpen {
                _ = handler.open(playground.name,
                                 with: options.xcodePath,
                                 temporary: shouldStore)
            }
            return .success(())
        case let .failure(error):
            return .failure(error)
        }
    }
}
