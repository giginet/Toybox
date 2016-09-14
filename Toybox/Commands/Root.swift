import Foundation
import Commandant
import Result

public struct RootCommand: CommandType {
    public typealias Options = NoOptions<ToyboxError>
    public typealias ClientError = ToyboxError
    
    public init() {
    }
    
    public let verb = "root"
    public let function = "Show Playgrounds' root"
    
    public func run(_ options: Options) -> Result<(), ToyboxError> {
        let handler = PlaygroundHandler<FileSystemStorage>()
        let standardOutput = FileHandle.standardOutput
        if let data = handler.rootURL.path.data(using: .utf8) {
            standardOutput.write(data)
        }
        
        return .success()
    }
}
