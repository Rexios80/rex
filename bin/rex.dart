import 'package:args/command_runner.dart';

import 'command/clone.dart';
import 'command/create.dart';
import 'command/open.dart';
import 'command/switch.dart';

void main(List<String> args) {
  CommandRunner('rex', 'Tailored convenience commands for developer Rexios')
    ..addCommand(OpenCommand())
    ..addCommand(SwitchCommand())
    ..addCommand(CreateCommand())
    ..addCommand(CloneCommand())
    ..run(args);
}
