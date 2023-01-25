import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:rex/pens.dart';
import 'package:rex/run_process.dart';

class ViewCommand extends Command {
  @override
  final name = 'view';

  @override
  final description = 'View something useful';

  @override
  final invocation = 'rex view [subcommand] [arguments]';

  ViewCommand() {
    addSubcommand(ViewPubCommand());
    addSubcommand(ViewGithubCommand());
  }
}

class ViewPubCommand extends Command {
  @override
  final name = 'pub';

  @override
  final description = 'Open a package on pub.dev';

  @override
  late final invocation = 'rex view $name [package]';

  @override
  Future<void> run() async {
    final package = argResults?.rest.firstOrNull;
    if (package == null) {
      runner!.usageException(redPen('Specify a package to view'));
    }
    await runProcess('open', ['https://pub.dev/packages/$package']);
  }
}

class ViewGithubCommand extends Command {
  @override
  final name = 'github';

  @override
  final description = 'Open a repository on github.com';

  @override
  late final invocation = 'rex view $name [slug]';

  @override
  Future<void> run() async {
    final slug = argResults?.rest.firstOrNull;
    if (slug == null) {
      runner!.usageException(redPen('Please specify a repository to view'));
    }
    await runProcess('open', ['https://github.com/$slug']);
  }
}
