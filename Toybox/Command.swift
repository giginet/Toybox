import Foundation
import Commandant
import Result

public struct CreateOptions: OptionsType {
    public typealias ClientError = PlaygroundHandlerError
    let fileName: String?
    let platform: Platform
    
    static func create(_ platform: Platform) -> (String) -> CreateOptions {
        return { filename in self.init(fileName: filename, platform: platform) }
    }
    
    public static func evaluate(_ m: CommandMode) -> Result<CreateOptions, CommandantError<PlaygroundHandlerError>> {
        return create
            <*> m <| Option(key: "platform", defaultValue: Platform.iOS, usage: "Target platform (ios/macos/tvos)")
            <*> m <| Argument(defaultValue: nil, usage: "Playground file name to create")
    }
}

private class Foobar {}

public struct CreateCommand: CommandType {
    public typealias Options = CreateOptions
    public typealias ClientError = PlaygroundHandlerError
    
    public init() {
    }
    
    public let verb = "create"
    public let function = "Create new Playground"
    
    public func run(_ options: Options) -> Result<(), PlaygroundHandlerError> {
        let bundle = Bundle(for: Foobar.self)
        let handler = PlaygroundHandler<FileSystemStorage>()
        do {
            try handler.bootstrap()
        } catch let exception as PlaygroundHandlerError {
        } catch {
        }
        let fileName = options.fileName
        do {
            try handler.create(name: fileName, for: options.platform)
        } catch let exception as PlaygroundHandlerError {
            return .failure(exception)
        } catch {
        }
        
        return .success()
    }
}
