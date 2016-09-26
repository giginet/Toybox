import Foundation

public enum ToyboxError: Error {
    case bootstrapError
    case createError(String)
    case openError(String)
    case listError
    case duplicatedError(String)
    case versionError
}

public extension ToyboxError {
    var description: String {
        switch self {
        case .bootstrapError:
            return "Could not create workspace"
        case let .createError(playgroundName):
            return "Could not create Playground named '\(playgroundName)'"
        case let .openError(playgroundName):
            return "Could not open '\(playgroundName)'"
        case .listError:
            return "Could not read workspace"
        case let .duplicatedError(playgroundName):
            return "Playground '\(playgroundName)' is already exist. use '-f' flag to overwrite"
        case .versionError:
            return "Cpuld not detect toybox version"
        }
    }
}
