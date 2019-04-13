import Foundation
import ToyboxKit
import Commandant

struct RootCommand: CommandProtocol {
    typealias Options = NoOptions<ToyboxError>
    typealias ClientError = ToyboxError

    let verb = "root"
    let function = "Show Playgrounds' root"

    func run(_ options: Options) -> Result<(), ToyboxError> {
        let handler = ToyboxPlaygroundHandler()
        print(handler.rootURL.path)
        return .success(())
    }
}
