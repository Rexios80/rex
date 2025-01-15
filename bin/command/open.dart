import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:rex/pens.dart';
import 'package:rex/util.dart';
import 'package:path/path.dart' as p;

class OpenCommand extends Command {
  @override
  final name = 'open';

  @override
  final description = 'Open a project in in VSCode and Sublime Merge';

  @override
  final invocation = 'rex open [path]';

  @override
  Future<int> run() async {
    var path = argResults?.rest.firstOrNull ?? '.';
    if (!Directory(path).existsSync()) {
      print(yellowPen('No project found at path: $path'));

      // Attempt to find the project in the repos directory
      path = p.join(home, 'repos', path);
      if (!Directory(path).existsSync()) {
        print(redPen('No project found at path: $path'));
        return 1;
      }
    }

    if (Directory(p.join(path, '.git')).existsSync()) {
      print('Opening $path in Sublime Merge...');
      await runProcess('smerge', ['-b', path]);
    } else {
      print('No git repository found at $path');
    }

    final files = Directory(path).listSync();

    // Try to open an xcworkspace or xcodeproj file
    final xcworkspace =
        files.firstWhereOrNull((e) => e.path.endsWith('.xcworkspace'));
    if (xcworkspace != null) {
      final path = p.relative(xcworkspace.path);
      print('Opening $path in Xcode...');
      return runProcess('open', [path]);
    }

    final xcodeproj =
        files.firstWhereOrNull((e) => e.path.endsWith('.xcodeproj'));
    if (xcodeproj != null) {
      final path = p.relative(xcodeproj.path);
      print('Opening $path in Xcode...');
      return runProcess('open', [path]);
    }

    print('Opening $path in VSCode...');
    return runProcess('code', [path]);
  }
}
