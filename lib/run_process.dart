import 'dart:convert';
import 'dart:io';

import 'package:rex/pens.dart';

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
