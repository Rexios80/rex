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
    addSubcommand(ClonePubCommand());
    addSubcommand(CloneDartCommand('dart'));
    addSubcommand(CloneDartCommand('flutter'));
  }
}

class ClonePubCommand extends Command {
  @override
  final String name = 'pub';

  @override
  final description = 'Clone a pub package repository';

  @override
  late String invocation = 'rex clone $name [package]';

  @override
  Future<void> run() async {
    final package = argResults?.rest.firstOrNull;
    if (package == null) {
      runner!.usageException(redPen('Specify a package to clone'));
    }
    final url = await Pub.getPackageRepo(package);
    if (url == null) {
      print(redPen('Could not find a repository for $package'));
      return;
    }
    await runner!.run(['clone', 'dart', url]);
  }
}

class CloneDartCommand extends Command {
  @override
  final String name;

  @override
  late String description = 'Clone a $name project';

  @override
  late String invocation = 'rex clone $name [url]';

  /// The [name] does not affect the [run] method
  CloneDartCommand(this.name);

  @override
  Future<void> run() async {
    final url = argResults?.rest.firstOrNull;
    if (url == null) {
      runner!.usageException(redPen('Specify a URL to clone'));
    }
    final folderName = url.split('/').last;
    final folder = '$home/repos/$folderName';

    print('Cloning $url into $folder...');
    await runProcess('git', ['clone', url, folder]);
    await runProcess('puby', ['get'], workingDirectory: folder);

    await runner!.run(['open', folder]);
  }
}
