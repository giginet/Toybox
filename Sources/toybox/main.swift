import Foundation
import ToyboxKit
import Commandant
import Result

let registry = CommandRegistry<ToyboxError>()
registry.register(CreateCommand())
registry.register(OpenCommand())
registry.register(ListCommand())
registry.register(RootCommand())
registry.register(VersionCommand())

let helpCommand = HelpCommand(registry: registry)
registry.register(helpCommand)

var arguments = CommandLine.arguments
// Remove the executable name.
assert(arguments.count >= 1)
arguments.remove(at: 0)

registry.main(defaultVerb: helpCommand.verb) { error in
    fputs(error.description + "\n", stderr)
}
