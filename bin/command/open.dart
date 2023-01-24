import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:rex/run_process.dart';

class OpenCommand extends Command {
  @override
  final name = 'open';

  @override
  final description = 'Open a project in in VSCode and Sublime Merge';

  @override
  final invocation = 'rex open [path]';

  @override
  Future<void> run() async {
    final path = argResults?.rest.firstOrNull ?? '.';
    print('Opening $path in VSCode and Sublime Merge...');
    await runProcess('smerge', ['-b', path]);
    await runProcess('code', [path]);
  }
}
