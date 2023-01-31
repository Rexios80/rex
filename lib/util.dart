import 'dart:convert';
import 'dart:io';

import 'package:rex/pens.dart';

/// Get the home directory
final String home = Platform.environment['HOME']!;

/// Decoder
const decoder = Utf8Decoder();

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
  );

  process.stdout.listen((e) => stdout.write(decoder.convert(e)));
  process.stderr.listen((e) => stderr.write(redPen(decoder.convert(e))));

  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    print(redPen('Process exited with code $exitCode'));
    exit(exitCode);
  }
}

/// Run a script string
Future<void> runScript(String script, {String? workingDirectory}) async {
  final commands = script.split('\n').map(
        (e) => RegExp(r'[\""].+?[\""]|[^ ]+')
            .allMatches(e)
            .map((e) => e.group(0)!.replaceAll('"', '')),
      );
  for (final command in commands) {
    final executable = command.first;
    final arguments = command.skip(1).toList();
    await runProcess(executable, arguments, workingDirectory: workingDirectory);
  }
}
