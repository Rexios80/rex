import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:rex/scripts.dart';
import 'package:rex/util.dart';

class ScriptCommand extends Command {
  @override
  final String name = 'script';

  @override
  String get description {
    final buffer = StringBuffer('Available scripts:\n');
    final longestName = scripts.map((s) => s.name.length).max;
    for (final script in scripts) {
      final space = ' ' * (longestName - script.name.length + 3);
      buffer.writeln('  ${script.name}$space${script.description}');
    }
    return buffer.toString();
  }

  @override
  final String invocation = 'rex script [name]';

  @override
  Future<void> run() async {
    final name = argResults?.rest.firstOrNull;
    if (name == null) {
      runner!.usageException('Specify a script to run');
    }

    final script = scripts.firstWhereOrNull((s) => s.name == name);
    if (script == null) {
      runner!.usageException('Unknown script: $name');
    }

    await runScript(script.script);
  }
}
