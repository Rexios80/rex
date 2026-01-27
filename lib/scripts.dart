import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:io/io.dart';
import 'package:rex/util.dart';

/// The following script strings must follow a few rules:
/// - No empty lines
/// - No comments
/// - Each line is a completely self-contained command
abstract class Scripts {
  /// https://gist.github.com/maciekish/66b6deaa7bc979d0a16c50784e16d697
  static const resetXcode = r'''
killall Xcode
xcrun -k
xcodebuild -alltargets clean
rm -rf "$(getconf DARWIN_USER_CACHE_DIR)/org.llvm.clang/ModuleCache"
rm -rf "$(getconf DARWIN_USER_CACHE_DIR)/org.llvm.clang.$(whoami)/ModuleCache"
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf ~/Library/Caches/com.apple.dt.Xcode/*
open /Applications/Xcode.app''';

  /// Initialize a git repository and commit all files
  static const gitInit = r'''
git init
git add .
git commit -m "Initial commit"''';

  /// Gradle sync
  static const gradleSync = r'''
./gradlew prepareKotlinBuildScriptModel''';

  /// embedme
  static const embedme = 'npx embedme **/*.md';

  /// Run a script string
  static Future<int> run(String script, {String? workingDirectory}) async {
    final commands = script
        .split('\n')
        .map(
          (e) => RegExp(
            r'[\""].+?[\""]|[^ ]+',
          ).allMatches(e).map((e) => e.group(0)?.replaceAll('"', '')).nonNulls,
        );
    var exitCode = 0;
    for (final command in commands) {
      final executable = command.first;
      final arguments = command.skip(1).toList();
      exitCode |= await runProcess(
        executable,
        arguments,
        workingDirectory: workingDirectory,
      );
      if (exitCode != 0) break;
    }
    return exitCode;
  }
}

/// Reset Xcode to hopefully fix build issues
class ResetXcodeCommand extends Command {
  @override
  final name = 'reset-xcode';

  @override
  final description = 'Reset Xcode';

  @override
  Future<int> run() => Scripts.run(Scripts.resetXcode);
}

/// Initialize a git repository
class GitInitCommand extends Command {
  @override
  final name = 'git-init';

  @override
  final description = 'Initialize a git repository and commit all files';

  @override
  Future<int> run() => Scripts.run(Scripts.gitInit);
}

/// Gradle sync
class GradleSyncCommand extends Command {
  @override
  final name = 'gradle-sync';

  @override
  final description = 'Gradle sync';

  @override
  Future<int> run() => Scripts.run(Scripts.gradleSync);
}

/// Embed code snippets in markdown files
class EmbedmeCommand extends Command {
  @override
  final name = 'embedme';

  @override
  final description = 'Embed code snippets in markdown files';

  @override
  Future<int> run() => Scripts.run(Scripts.embedme);
}

/// Ensure ports are free and start Firebase emulators with caching
///
/// Ports from https://github.com/firebase/firebase-tools/blob/master/src/emulator/constants.ts
class FbemuCommand extends Command {
  static const _ports = {
    4000,
    4400,
    4500,
    5000,
    5001,
    8080,
    8085,
    9000,
    9099,
    9199,
    9299,
    9399,
  };
  @override
  final name = 'fbemu';

  @override
  final description =
      'Ensure ports are free and start Firebase emulators with caching';

  @override
  Future<int> run() {
    for (final port in _ports) {
      final result = Process.runSync('lsof', ['-t', '-i', 'tcp:$port']);
      if (result.exitCode != 0) continue;

      final output = result.stdout.toString().trim();
      if (output.isEmpty) continue;

      final pids = output.split('\n');
      for (final pid in pids) {
        Process.runSync('kill', [pid]);
      }
    }

    return runProcess('firebase', [
      'emulators:start',
      '--export-on-exit=emcache',
      '--import=emcache',
    ]);
  }
}

/// Import a certificate to Android Studio's keystore
class ImportCertCommand extends Command {
  @override
  final argParser = ArgParser()
    ..addOption('path', abbr: 'p', help: 'Android Studio path', mandatory: true)
    ..addOption('alias', abbr: 'a', help: 'Certificate alias', mandatory: true)
    ..addOption(
      'file',
      abbr: 'f',
      help: 'Certificate file path',
      mandatory: true,
    );

  @override
  final name = 'asic';

  @override
  final description = 'Import a certificate to Android Studio\'s keystore';

  @override
  Future<int> run() async {
    final argResults = this.argResults;
    if (argResults == null) return ExitCode.software.code;

    final path = argResults['path'] as String;
    final alias = argResults['alias'] as String;
    final file = argResults['file'] as String;

    return runProcess('$path/Contents/jbr/Contents/Home/bin/keytool', [
      '-importcert',
      '-trustcacerts',
      '-alias',
      alias,
      '-file',
      file,
      '-keystore',
      '$path/Contents/jbr/Contents/Home/lib/security/cacerts',
      '-storepass',
      'changeit',
    ]);
  }
}
