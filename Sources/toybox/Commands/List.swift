import Foundation
import ToyboxKit
import Commandant
import Result

struct ListOptions: OptionsProtocol {
    typealias ClientError = ToyboxError
    let platform: Platform?

    static func create(_ platform: Platform?) -> ListOptions {
        return self.init(platform: platform)
    }

    static func evaluate(_ m: CommandMode) -> Result<ListOptions, CommandantError<ToyboxError>> {
        return create
            <*> m <| Option<Platform?>(key: "platform", defaultValue: nil, usage: "Platform to list (ios/mac/tvos)")
    }
}

struct ListCommand: CommandProtocol {
    typealias Options = ListOptions
    typealias ClientError = ToyboxError

    let verb = "list"
    let function = "List the Playground"

    func run(_ options: Options) -> Result<(), ToyboxError> {
        let handler = ToyboxPlaygroundHandler()
        switch handler.list(for: options.platform) {
        case let .success(playgrounds):
            let exportString = playgrounds.joined(separator: "\n")
            println(object: exportString)
        case let .failure(error):
            return .failure(error)
        }
        return .success(())
    }
}
