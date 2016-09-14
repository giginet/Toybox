import Foundation
import Commandant
import Result

public struct ListOptions: OptionsType {
    public typealias ClientError = ToyboxError
    let platform: Platform?
    
    static func create(_ platform: Platform?) -> ListOptions {
        return self.init(platform: platform)
    }
    
    public static func evaluate(_ m: CommandMode) -> Result<ListOptions, CommandantError<ToyboxError>> {
        return create
            <*> m <| Option<Platform?>(key: "platform", defaultValue: nil, usage: "Platform to list (ios/mac/tvos)")
    }
}

public struct ListCommand: CommandType {
    public typealias Options = ListOptions
    public typealias ClientError = ToyboxError
    
    public init() {
    }
    
    public let verb = "list"
    public let function = "List the Playground"
    
    public func run(_ options: Options) -> Result<(), ToyboxError> {
        let handler = PlaygroundHandler<FileSystemStorage>()
        do {
            let playgrounds = try handler.list(for: options.platform)
            let exportString = playgrounds.joined(separator: "\n")
            let standardOutput = FileHandle.standardOutput
            if let data = exportString.data(using: .utf8) {
                standardOutput.write(data)
            }
        } catch let exception as ToyboxError {
            return .failure(exception)
        } catch {
        }
        
        return .success()
    }
}
