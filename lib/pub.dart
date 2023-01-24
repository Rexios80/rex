import 'package:pub_api_client/pub_api_client.dart';

/// Access to pub data
class Pub {
  static final _client = PubClient();

  /// Get the repository URL for a package
  static Future<String?> getPackageRepo(String packageName) async {
    final info = await _client.packageInfo(packageName);
    final homepage = info.latestPubspec.homepage;
    if (homepage != null && homepage.contains('github.com')) {
      return homepage;
    }

    return info.latestPubspec.unParsedYaml?['repository'];
  }
}
