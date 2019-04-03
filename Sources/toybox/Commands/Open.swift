import Foundation
import ToyboxKit
import Commandant
import Result

struct OpenOptions: OptionsProtocol {
    typealias ClientError = ToyboxError
    let fileName: String
    let xcodePath: URL?

    static func create(_ fileName: String) -> (String?) -> OpenOptions {
        return { xcodePathString in
            let xcodePath: URL?
            if let xcodePathString = xcodePathString {
                xcodePath = URL(fileURLWithPath: xcodePathString)
            } else {
                xcodePath = nil
            }
            return self.init(fileName: fileName, xcodePath: xcodePath)
        }
    }

    static func evaluate(_ m: CommandMode) -> Result<OpenOptions, CommandantError<ToyboxError>> {
        return create
            <*> m <| Argument(defaultValue: "", usage: "Playground file name to open")
            <*> m <| Option<String?>(key: "xcode-path", defaultValue: nil, usage: "Xcode path to open with")
    }
}

struct OpenCommand: CommandProtocol {
    typealias Options = OpenOptions
    typealias ClientError = ToyboxError

    let verb = "open"
    let function = "Open the Playground"

    func run(_ options: Options) -> Result<(), ToyboxError> {
        let handler = ToyboxPlaygroundHandler()
        let fileName = options.fileName
        guard let playground = handler.playground(for: fileName) else {
            return .failure(ToyboxError.openError("\(fileName) is not exist"))
        }
        if case let .failure(error) = handler.open(playground, with: options.xcodePath) {
            return .failure(error)
        }
        return .success(())
    }
}
