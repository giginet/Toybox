import Foundation
import Commandant
import Result

public struct CreateOptions: OptionsType {
    public typealias ClientError = NoError
    let fileName: String?
    let platform: Platform
    
    static func create(_ platform: Platform) -> (String) -> CreateOptions {
        return { filename in self.init(fileName: filename, platform: platform) }
    }
    
    public static func evaluate(_ m: CommandMode) -> Result<CreateOptions, CommandantError<NoError>> {
        return create
            <*> m <| Option(key: "platform", defaultValue: Platform.iOS, usage: "Target platform (ios/macos/tvos)")
            <*> m <| Argument(defaultValue: nil, usage: "Playground file name to create")
    }
}
public struct CreateCommand: CommandType {
    public typealias Options = CreateOptions
    public typealias ClientError = NoError
    
    public init() {
    }
    
    public let verb = "create"
    public let function = "Create new Playground"
    
    public func run(_ options: Options) -> Result<(), NoError> {
        let builder = PlaygroundBuilder<FileSystemStorage>()
        do {
            try builder.bootstrap()
        } catch {
        }
        let fileName = options.fileName ?? builder.defaultFileName()
        do {
            try builder.create(name: fileName, for: options.platform)
        } catch {
        }
        
        return .success()
    }
}
