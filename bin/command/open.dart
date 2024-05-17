import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart';
import 'package:rex/pens.dart';
import 'package:rex/util.dart';

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
    if (!Directory(path).existsSync()) {
      print(redPen('That path does not exist'));
      return;
    }

    print('Opening $path in Sublime Merge...');
    try {
      await runProcess('smerge', ['-b', path]);
    } catch (e) {
      print('Failed to open in Sublime Merge: $e');
    }

    final files = Directory(path).listSync();

    // Try to open an xcworkspace or xcodeproj file
    final xcworkspace =
        files.firstWhereOrNull((e) => e.path.endsWith('.xcworkspace'));
    if (xcworkspace != null) {
      final path = relative(xcworkspace.path);
      print('Opening $path in Xcode...');
      return runProcess('open', [path]);
    }

    final xcodeproj =
        files.firstWhereOrNull((e) => e.path.endsWith('.xcodeproj'));
    if (xcodeproj != null) {
      final path = relative(xcodeproj.path);
      print('Opening $path in Xcode...');
      return runProcess('open', [path]);
    }

    print('Opening $path in VSCode...');
    return runProcess('code', [path]);
  }
}
