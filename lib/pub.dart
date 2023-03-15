import 'package:pub_api_client/pub_api_client.dart';

/// Access to pub data
class Pub {
  static final _client = PubClient();

  /// Get the repository URL for a package
  static Future<String?> getPackageRepo(String packageName) async {
    final info = await _client.packageInfo(packageName);
    final sanitizedHomepage = _sanitizeRepoUrl(info.latestPubspec.homepage);
    if (sanitizedHomepage != null) {
      return sanitizedHomepage;
    }

    return _sanitizeRepoUrl(info.latestPubspec.unParsedYaml?['repository']);
  }

  static String? _sanitizeRepoUrl(String? url) {
    if (url == null) return null;

    final match =
        RegExp(r'https:\/\/github\.com\/(.+?)\/(.+?)($|\/)').firstMatch(url);
    if (match == null || match.groupCount < 2) return null;

    return 'https://github.com/${match[1]}/${match[2]}';
  }
}
