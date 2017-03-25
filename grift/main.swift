import Commandant
import Foundation
import GriftKit

let commands = CommandRegistry<GriftError>()
let dependenciesCommand = DependenciesCommand()
commands.register(dependenciesCommand)

commands.register(HelpCommand(registry: commands))

commands.main(defaultVerb: dependenciesCommand.verb) { (error) in
    fputs(error.description + "\n", stderr)
}
