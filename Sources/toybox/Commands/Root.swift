import Foundation
import ToyboxKit
import Commandant
import Result

struct RootCommand: CommandProtocol {
    typealias Options = NoOptions<ToyboxError>
    typealias ClientError = ToyboxError

    let verb = "root"
    let function = "Show Playgrounds' root"

    func run(_ options: Options) -> Result<(), ToyboxError> {
        let handler = ToyboxPlaygroundHandler()
        println(object: handler.rootURL.path)
        return .success(())
    }
}
