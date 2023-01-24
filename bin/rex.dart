import 'dart:async';

import 'package:args/command_runner.dart';

import 'command/clone.dart';
import 'command/create.dart';
import 'command/open.dart';
import 'command/reactivate.dart';
import 'command/switch.dart';
import 'command/view.dart';

void main(List<String> arguments) {
  runZonedGuarded(
    () => CommandRunner(
      'rex',
      'Tailored convenience commands for developer Rexios',
    )
      ..addCommand(OpenCommand())
      ..addCommand(SwitchCommand())
      ..addCommand(CreateCommand())
      ..addCommand(CloneCommand())
      ..addCommand(ViewCommand())
      ..addCommand(ReactivateCommand())
      ..run(arguments),
    (error, stack) => print(error),
  );
}
