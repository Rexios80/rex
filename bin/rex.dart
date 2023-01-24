import 'dart:io';

import 'package:args/args.dart';
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
    addSubcommand(CreateDartCommand('dart'));
    addSubcommand(CreateDartCommand('flutter'));
  }
}

class CreateDartCommand extends Command {
  @override
  final String name;

  @override
  late String description = 'Create a new $name project';

  @override
  late String invocation = 'rex create $name [arguments]';

  CreateDartCommand(this.name) {
    argParser.addFlag(
      'package',
      abbr: 'p',
      negatable: false,
      help: 'Use if creating a package',
    );
  }

  @override
  void run() {
    print('Creating a new $name project...');
    final args = argResults?.rest ?? [];
    Process.runSync(name, ['create', ...args]);

    final path = args.last;
    final pubspec = File('$path/pubspec.yaml');
    final pubspecContent = pubspec
        .readAsStringSync()
        // Remove all comments including leading spaces
        .replaceAll(RegExp('[ ]*#.*'), '')
        // Fix `publish_to` line
        .replaceFirst(RegExp('publish_to: .*'), 'publish_to: none')
        // Remove `cupertino_icons` package
        .replaceFirst(RegExp('cupertino_icons: .*'), '')
        // Remove any `lints` package
        .replaceFirst(RegExp('.*lints: .*'), '')
        // Remove extra newlines
        .replaceAll(RegExp('\n\n\n+'), '\n\n');

    pubspec.writeAsStringSync(pubspecContent);

    // Replace default lints with my own
    Process.runSync(
      name,
      ['pub', 'add', 'rexios_lints', '--dev'],
      workingDirectory: path,
    );

    File('$path/.analysis_options.yaml')
        .writeAsStringSync('include: package:rexios_lints/$name/core.yaml');
  }
}
