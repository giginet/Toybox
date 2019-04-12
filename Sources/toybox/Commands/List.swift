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

private func prettyList(_ playgrounds: [Playground]) -> String {
    let maxNameCount = playgrounds.map { $0.name.count }.max() ?? 0
    let maxPlatformCount = playgrounds.map { $0.platform.rawValue.count }.max() ?? 0
    let maxContentLengthCount = playgrounds.map { $0.contentLength ?? 0 }.max() ?? 0
    func pad(_ text: String, to count: Int, trailing: Bool = false) -> String {
        let whitespaceCount = count - text.count
        let whitespaces = String(repeating: " ", count: whitespaceCount)
        if trailing {
            return "\(whitespaces)\(text)"
        } else {
            return "\(text)\(whitespaces)"
        }
    }
    return playgrounds.map { playground in
        return [pad(playground.name, to: maxNameCount),
                pad(String(playground.contentLength ?? 0), to: maxContentLengthCount, trailing: true),
                pad(playground.platform.displayName, to: maxPlatformCount)
            ].joined(separator: " ")
        }.joined(separator: "\n")
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
            if playgrounds.isEmpty {
                print("There are no playgrounds.")
            } else {
                let exportString = prettyList(playgrounds)
                print(exportString)
            }
        case let .failure(error):
            return .failure(error)
        }
        return .success(())
    }
}
