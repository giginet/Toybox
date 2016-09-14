import Foundation
import ToyboxKit
import Commandant
import Result

struct OpenOptions: OptionsType {
    typealias ClientError = ToyboxError
    let fileName: String
    let xcodePath: NSURL?
    
    static func create(_ fileName: String) -> (String?) -> OpenOptions {
        return { xcodePath in self.init(fileName: fileName, xcodePath: nil) }
    }
    
    static func evaluate(_ m: CommandMode) -> Result<OpenOptions, CommandantError<ToyboxError>> {
        return create
            <*> m <| Argument(defaultValue: "", usage: "Playground file name to open")
            <*> m <| Option<String?>(key: "xcode_path", defaultValue: nil, usage: "Xcode path to open with")
    }
}

struct OpenCommand: CommandType {
    typealias Options = OpenOptions
    typealias ClientError = ToyboxError
    
    init() {
    }
    
    let verb = "open"
    let function = "Open the Playground"
    
    func run(_ options: Options) -> Result<(), ToyboxError> {
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
