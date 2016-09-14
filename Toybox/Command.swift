import Foundation
import Commandant
import Result

public struct CreateOptions: OptionsType {
    public typealias ClientError = ToyboxError
    let fileName: String?
    let platform: Platform
    
    static func create(_ platform: Platform) -> ([String]) -> CreateOptions {
        return { fileNames in self.init(fileName: fileNames.first, platform: platform) }
    }
    
    public static func evaluate(_ m: CommandMode) -> Result<CreateOptions, CommandantError<ToyboxError>> {
        return create
            <*> m <| Option(key: "platform", defaultValue: Platform.iOS, usage: "Target platform (ios/macos/tvos)")
            <*> m <| Argument(defaultValue: [], usage: "Playground file name to create")
    }
}

private class Foobar {}

public struct CreateCommand: CommandType {
    public typealias Options = CreateOptions
    public typealias ClientError = ToyboxError
    
    public init() {
    }
    
    public let verb = "create"
    public let function = "Create new Playground"
    
    public func run(_ options: Options) -> Result<(), ToyboxError> {
        let bundle = Bundle(for: Foobar.self)
        let handler = PlaygroundHandler<FileSystemStorage>()
        do {
            try handler.bootstrap()
        } catch let exception as ToyboxError {
        } catch {
        }
        let fileName = options.fileName
        do {
            try handler.create(name: fileName, for: options.platform)
        } catch let exception as ToyboxError {
            return .failure(exception)
        } catch {
        }
        
        return .success()
    }
}

public struct OpenOptions: OptionsType {
    public typealias ClientError = ToyboxError
    let fileName: String
    let xcodePath: NSURL?
    
    static func create(_ fileName: String) -> (String?) -> OpenOptions {
        return { xcodePath in self.init(fileName: fileName, xcodePath: nil) }
    }
    
    public static func evaluate(_ m: CommandMode) -> Result<OpenOptions, CommandantError<ToyboxError>> {
        return create
            <*> m <| Argument(defaultValue: "", usage: "Playground file name to open")
            <*> m <| Option<String?>(key: "xcode_path", defaultValue: nil, usage: "Xcode path to open with")
    }
}

public struct OpenCommand: CommandType {
    public typealias Options = OpenOptions
    public typealias ClientError = ToyboxError
    
    public init() {
    }
    
    public let verb = "open"
    public let function = "Open the Playground"
    
    public func run(_ options: Options) -> Result<(), ToyboxError> {
        let bundle = Bundle(for: Foobar.self)
        let handler = PlaygroundHandler<FileSystemStorage>()
        let fileName = options.fileName
        do {
            try handler.open(name: fileName)
        } catch let exception as ToyboxError {
            return .failure(exception)
        } catch {
        }
        
        return .success()
    }
}
