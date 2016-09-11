import Foundation
import Commandant

enum Platform: String, ArgumentType {
    case iOS = "ios"
    case macOS = "macos"
    case tvOS = "tvos"
    
    static let name: String = "platform"
    
    /// Attempts to parse a value from the given command-line argument.
    static func fromString(_ string: String) -> Platform? {
        return Platform(rawValue: string)
    }
}
