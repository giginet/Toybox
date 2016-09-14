import Foundation

public enum ToyboxError: Error {
    case bootstrapError
    case createError
    case openError
    case listError
}

public extension ToyboxError {
    var description: String {
        switch self {
        case .bootstrapError:
            return "could not create workspace"
        case .createError:
            return "could not create playground"
        case .openError:
            return "could not open"
        case .listError:
            return "could not read workspace"
        }
    }
}
