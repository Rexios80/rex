import 'dart:io';

import 'package:pub_api_client/pub_api_client.dart';

/// Access to pub data
class Pub {
  static final _client = PubClient();

  /// Get the repository URL for a package
  static Future<String?> getPackageRepo(String packageName) async {
    final info = await _client.packageInfo(packageName);
    final homepage = info.latestPubspec.homepage;
    if (homepage != null) {
      final match = RegExp(r'https:\/\/github\.com\/(.+?)\/(.+?)($|\/)')
          .firstMatch(homepage);

      if (match != null && match.groupCount >= 2) {
        final url = 'https://github.com/${match[1]}/${match[2]}';
        final result = Process.runSync('git', ['ls-remote', url]);
        if (result.exitCode == 0) {
          return homepage;
        }
      }
    }

    return info.latestPubspec.unParsedYaml?['repository'];
  }
}
