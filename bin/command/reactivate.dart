import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:rex/util.dart';

class ReactivateCommand extends Command {
  @override
  final name = 'reactivate';

  @override
  final description =
      'Reactivate a pub package. If no package is specified, rex will be reactivated from git. Specify "." to reactivate the current directory.';

  @override
  final invocation = 'rex reactivate [package]';

  @override
  Future<void> run() async {
    final package = argResults?.rest.firstOrNull;

    if (package == null) {
      print('Reactivating rex...');
      await runProcess('dart', [
        'pub',
        'global',
        'activate',
        '--source',
        'git',
        'https://github.com/Rexios80/rex',
      ]);
    } else if (package == '.') {
      print('Reactivating current directory...');
      await runProcess('dart', [
        'pub',
        'global',
        'activate',
        '--source',
        'path',
        '.',
      ]);
    } else {
      print('Reactivating $package...');
      await runProcess('dart', ['pub', 'global', 'deactivate', package]);
      await runProcess('dart', ['pub', 'global', 'activate', package]);
    }
  }
}
