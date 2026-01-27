import 'dart:async';
import 'dart:io';

/// Get the home directory
final String home = Platform.environment['HOME'] ?? '';

/// Run a process and print output to [stdout] and [stderr]
Future<int> runProcess(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
}) async {
  final process = await Process.start(
    executable,
    arguments,
    workingDirectory: workingDirectory,
    runInShell: true,
    mode: ProcessStartMode.inheritStdio,
  );

  return process.exitCode;
}
