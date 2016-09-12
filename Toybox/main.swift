import Foundation
import ToyboxKit
import Commandant
import Result

let registry = CommandRegistry<PlaygroundHandlerError>()
registry.register(CreateCommand())

let helpCommand = HelpCommand(registry: registry)
registry.register(helpCommand)

var arguments = CommandLine.arguments
// Remove the executable name.
assert(arguments.count >= 1)
arguments.remove(at: 0)

if let verb = arguments.first {
    // Remove the command name.
    arguments.remove(at: 0)
    
    if let result = registry.runCommand(verb, arguments: arguments) {
        // Handle success or failure.
        print(result)
    } else {
        // Unrecognized command.
    }
} else {
    // No command given.
}
