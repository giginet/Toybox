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
    
    static func create(_ platform: Platform) -> ([String]) -> (Bool) -> (Bool) -> CreateOptions {
        return { fileNames in
            { force in
                { noOpen in
                    self.init(fileName: fileNames.first, platform: platform, force: force, noOpen: noOpen)
                }
            }
        }
    }
    
    static func evaluate(_ m: CommandMode) -> Result<CreateOptions, CommandantError<ToyboxError>> {
        return create
            <*> m <| Option(key: "platform", defaultValue: Platform.iOS, usage: "Target platform (ios/macos/tvos)")
            <*> m <| Argument(defaultValue: [], usage: "Playground file name to create")
            <*> m <| Switch(flag: "f", key: "force", usage: "Whether to overwrite existing playground")
            <*> m <| Switch(flag: "s", key: "no-open", usage: "Whether to open new playground")
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
        
        let fileName = options.fileName
        switch handler.create(name: fileName, for: options.platform, force: options.force) {
        case let .success(playground):
            if !options.noOpen {
                _ = handler.open(name: playground.name)
            }
            return .success()
        case let .failure(error):
            return .failure(error)
        }
    }
}
