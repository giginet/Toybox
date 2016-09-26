import Foundation
import ToyboxKit
import Commandant
import Result

struct OpenOptions: OptionsProtocol {
    typealias ClientError = ToyboxError
    let fileName: String
    let xcodePath: NSURL?

    static func create(_ fileName: String) -> (String?) -> OpenOptions {
        return { xcodePath in self.init(fileName: fileName, xcodePath: nil) }
    }

    static func evaluate(_ m: CommandMode) -> Result<OpenOptions, CommandantError<ToyboxError>> {
        return create
            <*> m <| Argument(defaultValue: "", usage: "Playground file name to open")
            <*> m <| Option<String?>(key: "xcode_path", defaultValue: nil, usage: "Xcode path to open with")
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
        if case let .failure(error) = handler.open(fileName) {
            return .failure(error)
        }
        return .success()
    }
}
