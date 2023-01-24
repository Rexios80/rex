import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
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
      runner!.usageException('Please specify a package to view');
    }
    await runProcess('open', ['https://pub.dev/packages/$package']);
  }
}
