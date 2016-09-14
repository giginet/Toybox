import Foundation
import ToyboxKit
import Commandant
import Result

struct RootCommand: CommandType {
    typealias Options = NoOptions<ToyboxError>
    typealias ClientError = ToyboxError
    
    init() {
    }
    
    let verb = "root"
    let function = "Show Playgrounds' root"
    
    func run(_ options: Options) -> Result<(), ToyboxError> {
        let handler = PlaygroundHandler<FileSystemStorage>()
        let standardOutput = FileHandle.standardOutput
        if let data = handler.rootURL.path.data(using: .utf8) {
            standardOutput.write(data)
        }
        
        return .success()
    }
}
