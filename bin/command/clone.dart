import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:rex/run_process.dart';

class CloneCommand extends Command {
  @override
  final name = 'create';

  @override
  final description = 'Clone a project';

  @override
  final invocation = 'rex clone [framework] [arguments]';

  CloneCommand() {
    addSubcommand(CloneDartCommand('dart'));
    addSubcommand(CloneDartCommand('flutter'));
  }
}

class CloneDartCommand extends Command {
  @override
  final String name;

  @override
  late String description = 'Clone a $name project';

  @override
  late String invocation = 'rex clone $name [arguments]';

  CloneDartCommand(this.name);

  @override
  Future<void> run() async {
    final url = argResults?.rest.firstOrNull;
    if (url == null) {
      runner!.usageException('Please specify a URL to clone');
    }
    final folderName = url.split('/').last;
    final folder = '~/repos/$folderName';

    print('Cloning $url into $folder...');
    await runProcess('git', ['clone', url, folder]);
    await runProcess(name, ['pub', 'get'], workingDirectory: folder);

    await runner!.run(['open', folder]);
  }
}
