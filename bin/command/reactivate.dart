import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:rex/util.dart';

const _activateArgs = ['pub', 'global', 'activate'];
const _deactivateArgs = ['pub', 'global', 'deactivate'];

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
      await runProcess('dart', [..._deactivateArgs, 'rex']);
      await runProcess('dart', [
        ..._activateArgs,
        '--source',
        'git',
        'https://github.com/Rexios80/rex',
      ]);
    } else if (package == '.') {
      final pubspec = Pubspec.parse(File('pubspec.yaml').readAsStringSync());
      final package = pubspec.name;

      print('Reactivating $package from source...');
      File('pubspec.lock').deleteSync();
      await runProcess('dart', ['pub', 'get']);
      await runProcess('dart', [..._deactivateArgs, package]);
      await runProcess('dart', [..._activateArgs, '--source', 'path', '.']);
    } else {
      print('Reactivating $package...');
      await runProcess('dart', [..._deactivateArgs, package]);
      await runProcess('dart', [..._activateArgs, package]);
    }
  }
}
