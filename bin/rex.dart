import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';

import 'command/clone.dart';
import 'command/create.dart';
import 'command/open.dart';
import 'command/reactivate.dart';
import 'command/script.dart';
import 'command/view.dart';

void main(List<String> arguments) async {
  await runZonedGuarded(() async {
    final runner =
        CommandRunner(
            'rex',
            'Tailored convenience commands for developer Rexios',
          )
          ..addCommand(OpenCommand())
          ..addCommand(CreateCommand())
          ..addCommand(CloneCommand())
          ..addCommand(ViewCommand())
          ..addCommand(ReactivateCommand())
          ..addCommand(ScriptCommand());
    await runner.run(arguments);
  }, (error, stack) => print(error));

  exit(0);
}
