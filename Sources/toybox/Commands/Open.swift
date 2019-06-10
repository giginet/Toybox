import Foundation
import ToyboxKit
import Commandant

struct OpenOptions: OptionsProtocol {
    typealias ClientError = ToyboxError
    let fileName: String
    let xcode: XcodeSpecifier?

    static func create(_ fileName: String) -> (String?) -> (String?) -> OpenOptions {
        return { xcodePathString in { xcodeVersion in
            let xcode: XcodeSpecifier?
            if let xcodePathString = xcodePathString {
                xcode = .path(URL(fileURLWithPath: xcodePathString))
            } else if let xcodeVersion = xcodeVersion {
                xcode = .version(xcodeVersion)
            } else {
                xcode = nil
            }
            return self.init(fileName: fileName, xcode: xcode)
            } }
    }

    static func evaluate(_ m: CommandMode) -> Result<OpenOptions, CommandantError<ToyboxError>> {
        return create
            <*> m <| Argument(defaultValue: "", usage: "Playground file name to open")
            <*> m <| Option<String?>(key: "xcode-path", defaultValue: nil, usage: "Xcode path to open with")
            <*> m <| Option<String?>(key: "xcode-version", defaultValue: nil, usage: "Xcode version to open with")
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
            return .failure(ToyboxError.openError(fileName))
        }
        if case let .failure(error) = handler.open(playground, with: options.xcode) {
            return .failure(error)
        }
        return .success(())
    }
}
