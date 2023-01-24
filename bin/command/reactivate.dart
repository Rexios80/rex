import 'package:args/command_runner.dart';
import 'package:rex/run_process.dart';
import 'package:rex/util.dart';

class ReactivateCommand extends Command {
  @override
  final name = 'reactivate';

  @override
  final description = 'Reactivate this tool from source';

  @override
  Future<void> run() async {
    print('Reactivating...');
    await runProcess(
      'dart',
      ['pub', 'global', 'activate', '--source', 'path', '$home/repos/rex'],
    );
  }
}
