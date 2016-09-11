import Foundation
import ToyboxKit
import Commandant
import Result

print("Hello, World!")
let commands = CommandRegistry<NoError>()
let command = CreateCommand()
commands.register(command)

var arguments = CommandLine.arguments

// Remove the executable name.
assert(arguments.count >= 1)
arguments.remove(at: 0)

if let verb = arguments.first {
    // Remove the command name.
    arguments.remove(at: 0)
    
    if let result = commands.runCommand(verb, arguments: arguments) {
        // Handle success or failure.
    } else {
        // Unrecognized command.
    }
} else {
    // No command given.
}
