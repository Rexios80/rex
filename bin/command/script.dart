import 'package:args/command_runner.dart';
import 'package:rex/scripts.dart';

class ScriptCommand extends Command {
  @override
  final String name = 'script';

  @override
  final description = 'Run a script by name';

  ScriptCommand() {
    addSubcommand(ResetXcodeCommand());
    addSubcommand(GitInitCommand());
    addSubcommand(GradleSyncCommand());
    addSubcommand(EmbedmeCommand());
    addSubcommand(FbemuCommand());
    addSubcommand(ImportCertCommand());
  }
}
