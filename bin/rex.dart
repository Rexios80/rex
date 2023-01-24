import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';

void main(List<String> args) {
  final runner =
      CommandRunner('rex', 'Tailored convenience commands for developer Rexios')
        ..addCommand(OpenCommand())
        ..addCommand(SwitchCommand())
        ..addCommand(CreateCommand());
  runner.run(args);
}

class OpenCommand extends Command {
  @override
  final name = 'open';

  @override
  final description = 'Open a project in in VSCode and Sublime Merge';

  @override
  final invocation = 'rex open [path]';

  @override
  void run() {
    final path = argResults?.rest.firstOrNull ?? '.';
    print('Opening $path in VSCode and Sublime Merge...');
    Process.runSync('smerge', [path]);
    Process.runSync('code', [path]);
  }
}

class SwitchCommand extends Command {
  @override
  final name = 'switch';

  @override
  final description = 'Open a project reusing the current windows';

  @override
  final invocation = 'rex switch [path]';

  @override
  void run() {
    final path = argResults?.rest.firstOrNull ?? '.';
    print('Opening $path in existing VSCode and Sublime Merge windows...');
    Process.runSync('smerge', [path]);
    Process.runSync('code', ['-r', path]);
  }
}

class CreateCommand extends Command {
  @override
  final name = 'create';

  @override
  final description = 'Create a new project';

  @override
  final invocation = 'rex create [framework] [arguments]';

  CreateCommand() {
    addSubcommand(CreateDartCommand());
    addSubcommand(CreateFlutterCommand());
  }
}

class CreateDartCommand extends Command with CreateDartMixin {
  @override
  final name = 'dart';
}

class CreateFlutterCommand extends Command with CreateDartMixin {
  @override
  final name = 'flutter';
}

mixin CreateDartMixin on Command {
  @override
  String get description => 'Create a new $name project';

  @override
  String get invocation => 'rex create $name [arguments]';

  @override
  void run() {
    print('Creating a new $name project...');
    final args = argResults?.rest ?? [];
    Process.runSync('dart', ['create', ...args]);

    final path = args.last;
    final pubspec = File('$path/pubspec.yaml');
    final pubspecContent = pubspec
        .readAsStringSync()
        // Remove all comments including leading spaces
        .replaceAll(RegExp('[ ]*#.*'), '')
        .replaceFirst(RegExp('publish_to: .*'), 'publish_to: none')
        .replaceFirst(RegExp('cupertino_icons: .*'), '')
        .replaceFirst(RegExp('.*lints: .*'), '');

    pubspec.writeAsStringSync(pubspecContent);

    // Replace default lints with my own
    Process.runSync(
      name,
      ['pub', 'add', 'rexios_lints', '--dev'],
      workingDirectory: path,
    );
    Process.runSync('yamlfmt', ['.'], workingDirectory: path);
  }
}
