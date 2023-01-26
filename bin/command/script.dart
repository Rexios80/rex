import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:rex/scripts.dart';
import 'package:rex/util.dart';

class ScriptCommand extends Command {
  @override
  final String name = 'script';

  @override
  final String description = 'Run a script by name';

  @override
  final String invocation = 'rex script [name]';

  @override
  Future<void> run() async {
    final name = argResults?.rest.firstOrNull;
    if (name == null) {
      runner!.usageException('Specify a script to run');
    }

    final script = scriptMap[name];
    if (script == null) {
      runner!.usageException('Unknown script: $name');
    }

    await runScript(script);
  }
}
