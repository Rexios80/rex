import 'dart:async';
import 'dart:io';

import 'package:rex/pens.dart';

/// Get the home directory
final String home = Platform.environment['HOME']!;

/// Run a process and print output to [stdout] and [stderr]
Future<void> runProcess(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
}) async {
  final process = await Process.start(
    executable,
    arguments,
    workingDirectory: workingDirectory,
    runInShell: true,
    mode: stdin.hasTerminal
        ? ProcessStartMode.inheritStdio
        : ProcessStartMode.normal,
  );

  unawaited(stdout.addStream(process.stdout));
  unawaited(stderr.addStream(process.stderr));

  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    print(redPen('Process exited with code $exitCode'));
    exit(exitCode);
  }
}
