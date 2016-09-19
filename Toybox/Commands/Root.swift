import Foundation
import ToyboxKit
import Commandant
import Result

struct RootCommand: CommandType {
    typealias Options = NoOptions<ToyboxError>
    typealias ClientError = ToyboxError
    
    let verb = "root"
    let function = "Show Playgrounds' root"
    
    func run(_ options: Options) -> Result<(), ToyboxError> {
        let handler = PlaygroundHandler<FileSystemStorage>()
        toybox.println(object: handler.rootURL.path)
        return .success()
    }
}
