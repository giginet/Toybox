import Foundation
import ToyboxKit
import Commandant
import Result

struct ListOptions: OptionsType {
    typealias ClientError = ToyboxError
    let platform: Platform?
    
    static func create(_ platform: Platform?) -> ListOptions {
        return self.init(platform: platform)
    }
    
    static func evaluate(_ m: CommandMode) -> Result<ListOptions, CommandantError<ToyboxError>> {
        return create
            <*> m <| Option<Platform?>(key: "platform", defaultValue: nil, usage: "Platform to list (ios/mac/tvos)")
    }
}

struct ListCommand: CommandType {
    typealias Options = ListOptions
    typealias ClientError = ToyboxError
    
    let verb = "list"
    let function = "List the Playground"
    
    func run(_ options: Options) -> Result<(), ToyboxError> {
        let handler = PlaygroundHandler<FileSystemStorage>()
        do {
            let playgrounds = try handler.list(for: options.platform)
            let exportString = playgrounds.joined(separator: "\n")
            toybox.println(object: exportString)
        } catch let exception as ToyboxError {
            return .failure(exception)
        } catch {
        }
        
        return .success()
    }
}
