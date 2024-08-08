import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:rex/scripts.dart';

class ScriptCommand extends Command {
  @override
  final String name = 'script';

  @override
  String get description {
    final buffer = StringBuffer('''
Run a script by name
Available scripts:
''');
    final longestName = Scripts.all.map((s) => s.name.length).max;
    for (final script in Scripts.all) {
      final space = ' ' * (longestName - script.name.length + 3);
      buffer.writeln('  ${script.name}$space${script.description}');
    }
    return buffer.toString();
  }

  @override
  final String invocation = 'rex script [name]';

  @override
  Future<void> run() {
    final name = argResults?.rest.firstOrNull;
    if (name == null) {
      runner!.usageException('Specify a script to run');
    }

    final script = Scripts.all.firstWhereOrNull((s) => s.name == name);
    if (script == null) {
      runner!.usageException('Unknown script: $name');
    }

    return script.run();
  }
}
