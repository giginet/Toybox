import Foundation

public enum ToyboxError: Error {
    case bootstrapError
    case createError(String)
    case openError(String)
    case listError
    case duplicatedError(String)
    case versionError
    case xcodeNotFoundError(XcodeSpecifier?)
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
            return "Could not detect toybox version"
        case .xcodeNotFoundError(let xcode):
            guard let xcode = xcode else {
                return "Could not found any xcode"
            }
            switch xcode {
            case .path(let url):
                return "Xcode located at '\(url.path)' could not be found"
            case .version(let version):
                return "Xcode matching '\(version)' could not be found"
            }
        }
    }
}
