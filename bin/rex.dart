import 'dart:convert';
import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:rex/license.dart';

final magentaPen = AnsiPen()..magenta();
final greenPen = AnsiPen()..green();
final yellowPen = AnsiPen()..yellow();
final redPen = AnsiPen()..red();

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
  Future<void> run() async {
    final path = argResults?.rest.firstOrNull ?? '.';
    print('Opening $path in VSCode and Sublime Merge...');
    await runProcess('smerge', [path]);
    await runProcess('code', [path]);
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
  Future<void> run() async {
    final path = argResults?.rest.firstOrNull ?? '.';
    print('Opening $path in existing VSCode and Sublime Merge windows...');
    await runProcess('smerge', [path]);
    await runProcess('code', ['-r', path]);
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
    await runProcess('git', ['init'], workingDirectory: path);
    await runProcess('git', ['add', '.'], workingDirectory: path);
    await runProcess(
      'git',
      ['commit', '-m', 'Initial commit'],
      workingDirectory: path,
    );
  }
}

const decoder = Utf8Decoder();

Future<void> runProcess(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
}) async {
  final process = await Process.start(
    executable,
    arguments,
    workingDirectory: workingDirectory,
  );

  process.stdout.listen((e) => stdout.write(decoder.convert(e)));
  process.stderr.listen((e) => stderr.write(redPen(decoder.convert(e))));

  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    print(redPen('Process exited with code $exitCode'));
    exit(exitCode);
  }
}
