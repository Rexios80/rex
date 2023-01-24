import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:rex/run_process.dart';

class SwitchCommand extends Command {
  @override
  final name = 'switch';

  @override
  final description = 'Open a project reusing the current windows';

  @override
  final invocation = 'rex switch [path]';

  @override
  Future<void> run() async {
    final path = argResults?.rest.firstOrNull ?? '.';
    print('Opening $path in existing VSCode and Sublime Merge windows...');
    await runProcess('smerge', ['-b', path]);
    await runProcess('code', ['-r', path]);
  }
}
