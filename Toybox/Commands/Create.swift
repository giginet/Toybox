import Foundation
import ToyboxKit
import Commandant
import Result

struct CreateOptions: OptionsType {
    typealias ClientError = ToyboxError
    let fileName: String?
    let platform: Platform
    
    static func create(_ platform: Platform) -> ([String]) -> CreateOptions {
        return { fileNames in self.init(fileName: fileNames.first, platform: platform) }
    }
    
    static func evaluate(_ m: CommandMode) -> Result<CreateOptions, CommandantError<ToyboxError>> {
        return create
            <*> m <| Option(key: "platform", defaultValue: Platform.iOS, usage: "Target platform (ios/macos/tvos)")
            <*> m <| Argument(defaultValue: [], usage: "Playground file name to create")
    }
}

struct CreateCommand: CommandType {
    typealias Options = CreateOptions
    typealias ClientError = ToyboxError
    
    let verb = "create"
    let function = "Create new Playground"
    
    func run(_ options: Options) -> Result<(), ToyboxError> {
        let handler = PlaygroundHandler<FileSystemStorage>()
        do {
            try handler.bootstrap()
        } catch _ as ToyboxError {
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
