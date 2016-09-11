import Foundation
import Commandant
import Result

public struct CreateOptions: OptionsType {
    public typealias ClientError = NoError
    let platform: Platform
    
    static func create(_ platform: Platform) -> CreateOptions {
        return self.init(platform: platform)
    }
    
    public static func evaluate(_ m: CommandMode) -> Result<CreateOptions, CommandantError<NoError>> {
        return create
            <*> m <| Option(key: "platform", defaultValue: Platform.iOS, usage: "Target platform (ios/macos/tvos)")
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
        return .success()
    }
}
