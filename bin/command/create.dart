import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:rex/license.dart';
import 'package:rex/scripts.dart';
import 'package:rex/util.dart';

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
  late String description = 'Create a new $name project';

  @override
  late String invocation = 'rex create $name [arguments]';

  CreateDartCommand(this.name);

  @override
  Future<void> run() async {
    print('Creating a new $name project...');
    final args = argResults?.rest ?? [];
    await runProcess(name, ['create', ...args]);

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
    await runProcess(
      name,
      ['pub', 'add', 'rexios_lints', '--dev'],
      workingDirectory: path,
    );

    final isPackage = args.any(['package', 'plugin', 'plugin_ffi'].contains);
    final rules = isPackage ? 'package' : 'core';

    File('$path/analysis_options.yaml')
        .writeAsStringSync('include: package:rexios_lints/$name/$rules.yaml');

    if (isPackage) {
      File('$path/LICENSE').writeAsStringSync(generateLicenseText());
    }

    // Initialize a git repository
    await runScript(gitInit, workingDirectory: path);
    await runner!.run(['open', path]);
  }
}
