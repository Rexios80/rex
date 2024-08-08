import 'dart:async';
import 'dart:io';

import 'package:rex/util.dart';

/// Base class for scripts
abstract class RexScript {
  /// Name of the script
  final String name;

  /// Description of the script to display in help output
  final String description;

  /// Constructor
  const RexScript({
    required this.name,
    required this.description,
  });

  /// Run the script
  Future<void> run({String? workingDirectory});
}

/// A script that is run from a raw string
class RawScript extends RexScript {
  /// Script to run
  final String script;

  /// Constructor
  const RawScript({
    required super.name,
    required super.description,
    required this.script,
  });

  @override
  Future<void> run({String? workingDirectory}) async {
    final commands = script.split('\n').map(
          (e) => RegExp(r'[\""].+?[\""]|[^ ]+')
              .allMatches(e)
              .map((e) => e.group(0)!.replaceAll('"', '')),
        );
    for (final command in commands) {
      final executable = command.first;
      final arguments = command.skip(1).toList();
      await runProcess(
        executable,
        arguments,
        workingDirectory: workingDirectory,
      );
    }
  }
}

/// A script that runs dart code
class DartScript extends RexScript {
  /// Dart code to run
  final Future<void> Function({String? workingDirectory}) code;

  /// Constructor
  const DartScript({
    required super.name,
    required super.description,
    required this.code,
  });

  @override
  Future<void> run({String? workingDirectory}) =>
      code(workingDirectory: workingDirectory);
}

/// Contains scripts
abstract class Scripts {
  /// All available scripts
  static const all = [
    resetXcode,
    gitInit,
    gradleSync,
    fbemu,
  ];

  /// Reset Xcode
  static const resetXcode = RawScript(
    name: 'reset-xcode',
    description: 'Reset Xcode',
    script: _resetXcode,
  );

  /// Git init
  static const gitInit = RawScript(
    name: 'git-init',
    description: 'Initialize a git repository and commit all files',
    script: _gitInit,
  );

  /// Gradle sync
  static const gradleSync = RawScript(
    name: 'gradle-sync',
    description: 'Gradle sync',
    script: _gradleSync,
  );

  /// Firebase emulators
  static const fbemu = DartScript(
    name: 'fbemu',
    description:
        'Ensure ports are free and start Firebase emulators with caching',
    code: _fbemu,
  );
}

/// The following script strings must follow a few rules:
/// - No empty lines
/// - No comments
/// - Each line is a completely self-contained command

/// https://gist.github.com/maciekish/66b6deaa7bc979d0a16c50784e16d697
const _resetXcode = r'''
killall Xcode
xcrun -k
xcodebuild -alltargets clean
rm -rf "$(getconf DARWIN_USER_CACHE_DIR)/org.llvm.clang/ModuleCache"
rm -rf "$(getconf DARWIN_USER_CACHE_DIR)/org.llvm.clang.$(whoami)/ModuleCache"
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf ~/Library/Caches/com.apple.dt.Xcode/*
open /Applications/Xcode.app''';

/// Initialize a git repository and commit all files
const _gitInit = r'''
git init
git add .
git commit -m "Initial commit"''';

/// Gradle sync
const _gradleSync = r'''
./gradlew prepareKotlinBuildScriptModel''';

const _fbemuPorts = {
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

/// Ensure ports are free and start Firebase emulators with caching
///
/// Ports from https://github.com/firebase/firebase-tools/blob/master/src/emulator/constants.ts
Future<void> _fbemu({String? workingDirectory}) async {
  for (final port in _fbemuPorts) {
    final result = Process.runSync('lsof', ['-t', '-i', 'tcp:$port']);
    if (result.exitCode != 0) continue;

    final pid = result.stdout.toString().trim();
    if (pid.isEmpty) continue;

    Process.runSync('kill', [pid]);
  }

  return runProcess('firebase', [
    'emulators:start',
    '--export-on-exit=emcache',
    '--import=emcache',
  ]);
}
