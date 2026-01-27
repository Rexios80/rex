import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:rex/scripts.dart';
import 'package:rex/util.dart';
import 'package:path/path.dart' as p;

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
  final argParser = ArgParser.allowAnything();

  @override
  final String name;

  @override
  late var description = 'Create a new $name project';

  @override
  late var invocation = 'rex create $name [arguments]';

  CreateDartCommand(this.name);

  @override
  Future<void> run() async {
    final runner = this.runner;
    if (runner == null) return;

    print('Creating a new $name project...');
    final args = List.from(argResults?.rest ?? []);

    // If this project is part of a mono-repo
    // If so, do not git init or open the project
    final mono = args.remove('--mono');

    await runProcess(name, ['create', ...args]);

    final path = args.last;
    final pubspec = File(p.join(path, 'pubspec.yaml'));
    final pubspecContent = pubspec
        .readAsLinesSync()
        .whereNot(
          (e) =>
              // Remove all comments
              e.trim().startsWith('#') ||
              // Remove `cupertino_icons` package
              e.contains('cupertino_icons') ||
              // Remove any `lints` package
              e.contains('lints'),
        )
        .join('\n')
        // Fix `publish_to` line
        .replaceFirst(
          RegExp('publish_to: .*\n', multiLine: true),
          'publish_to: none',
        )
        // Remove extra newlines
        .replaceAll(RegExp('\n\n\n+', multiLine: true), '\n\n')
        .replaceFirstMapped(
          RegExp('^(.+):\n\n+', multiLine: true),
          (m) => '${m[1]}:\n',
        )
        .trim();

    pubspec.writeAsStringSync('$pubspecContent\n');

    // Replace default lints with my own
    await runProcess(name, [
      'pub',
      'add',
      'rexios_lints',
      '--dev',
    ], workingDirectory: path);

    final isPackage = args.any(['package', 'plugin', 'plugin_ffi'].contains);
    final ruleset = isPackage ? 'package' : 'core';

    File(p.join(path, 'analysis_options.yaml')).writeAsStringSync(
      'include: package:rexios_lints/$name/${ruleset}_extra.yaml\n',
    );

    // Initialize a git repository
    if (!mono) {
      await Scripts.run(Scripts.gitInit, workingDirectory: path);
      await runner.run(['open', path]);
    }
  }
}
