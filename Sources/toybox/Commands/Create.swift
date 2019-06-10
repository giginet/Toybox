import Foundation
import ToyboxKit
import Commandant

struct CreateOptions: OptionsProtocol {
    typealias ClientError = ToyboxError
    let fileName: String?
    let platform: Platform
    let force: Bool
    let noOpen: Bool
    let save: Bool
    let enableStandardInput: Bool
    let xcode: XcodeSpecifier?

    static func create(_ platform: Platform) -> (String?) -> (String?) -> (Bool) -> ([String]) -> (Bool) -> (Bool) -> (Bool) -> CreateOptions {
        return { xcodePathString in { xcodeVersion in { save in { fileNames in { force in { noOpen in { standardInput in
            let xcode: XcodeSpecifier?
            if let xcodePathString = xcodePathString {
                xcode = .path(URL(fileURLWithPath: xcodePathString))
            } else if let xcodeVersion = xcodeVersion {
                xcode = .version(xcodeVersion)
            } else {
                xcode = nil
            }
            return self.init(fileName: fileNames.first,
                             platform: platform,
                             force: force,
                             noOpen: noOpen,
                             save: save,
                             enableStandardInput: standardInput,
                             xcode: xcode)
            } } } } } }
        }
    }

    static func evaluate(_ m: CommandMode) -> Result<CreateOptions, CommandantError<ToyboxError>> {
        return create
            <*> m <| Option(key: "platform", defaultValue: Platform.iOS, usage: "Target platform (ios/macos/tvos)")
            <*> m <| Option<String?>(key: "xcode-path", defaultValue: nil, usage: "Xcode path to open with")
            <*> m <| Option<String?>(key: "xcode-version", defaultValue: nil, usage: "Xcode version to open with")
            <*> m <| Switch(flag: "s", key: "save", usage: "Whether to save to workspace as anonymous playground")
            <*> m <| Argument(defaultValue: [], usage: "Playground file name to create")
            <*> m <| Switch(flag: "f", key: "force", usage: "Whether to overwrite existing playground")
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

        let kind: ToyboxPlaygroundHandler.NewPlaygroundKind
        switch (options.save, options.fileName) {
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
                _ = handler.open(playground,
                                 with: options.xcode)
            }
            return .success(())
        case let .failure(error):
            return .failure(error)
        }
    }
}
