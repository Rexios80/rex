import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:rex/pens.dart';
import 'package:rex/pub.dart';
import 'package:rex/util.dart';

class CloneCommand extends Command {
  @override
  final name = 'clone';

  @override
  final description = 'Clone a project';

  @override
  final invocation = 'rex clone [framework] [arguments]';

  CloneCommand() {
    addSubcommand(CloneRawCommand());
    addSubcommand(ClonePubCommand());
    addSubcommand(CloneDartCommand('dart'));
    addSubcommand(CloneDartCommand('flutter'));
  }
}

abstract class BaseCloneCommand extends Command {
  @override
  final String name;

  BaseCloneCommand(this.name);

  Future<void> clone({Future<void> Function(String folder)? preprocess}) async {
    final runner = this.runner;
    if (runner == null) return;

    final url = argResults?.rest.firstOrNull;
    if (url == null) {
      runner.usageException(redPen('Specify a URL to clone'));
    }
    final folderName = url
        .split('/')
        .where((e) => e.isNotEmpty)
        .last
        .replaceAll('.git', '');
    final folder = '$home/repos/$folderName';

    print('Cloning $url into $folder...');
    await runProcess('git', ['clone', url, folder]);

    await preprocess?.call(folder);

    await runner.run(['open', folder]);
  }
}

class CloneRawCommand extends BaseCloneCommand {
  @override
  final description = 'Clone a repository without any special handling';

  @override
  late var invocation = 'rex clone $name [url]';

  CloneRawCommand() : super('raw');

  @override
  Future<void> run() => clone();
}

class ClonePubCommand extends Command {
  @override
  final name = 'pub';

  @override
  final description = 'Clone a pub package repository';

  @override
  late var invocation = 'rex clone $name [package]';

  @override
  Future<void> run() async {
    final runner = this.runner;
    if (runner == null) return;

    final package = argResults?.rest.firstOrNull;
    if (package == null) {
      runner.usageException(redPen('Specify a package to clone'));
    }
    final url = await Pub.getPackageRepo(package);
    if (url == null) {
      print(redPen('Could not find a repository for $package'));
      return;
    }
    await runner.run(['clone', 'dart', url]);
  }
}

class CloneDartCommand extends BaseCloneCommand {
  @override
  late var description = 'Clone and setup a $name project';

  @override
  late var invocation = 'rex clone $name [url]';

  /// The [name] does not affect the [run] method
  CloneDartCommand(super.name);

  @override
  Future<void> run() => clone(
    preprocess: (folder) =>
        runProcess('puby', ['link'], workingDirectory: folder),
  );
}
