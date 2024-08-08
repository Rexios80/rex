/// Data describing a rex script
class RexScript {
  /// String used to run the script
  final String name;

  /// Description of the script to show in help output
  final String description;

  /// Script to run
  final String script;

  /// Constructor
  const RexScript({
    required this.name,
    required this.description,
    required this.script,
  });
}

/// All available scripts
const scripts = [
  RexScript(
    name: 'reset-xcode',
    description: 'Reset Xcode',
    script: resetXcode,
  ),
  RexScript(
    name: 'git-init',
    description: 'Initialize a git repository and commit all files',
    script: gitInit,
  ),
  RexScript(
    name: 'gradle-sync',
    description: 'Gradle sync',
    script: gradleSync,
  ),
  RexScript(
    name: 'fbemu',
    description:
        'Ensure ports are free and start Firebase emulators with caching',
    script: fbemu,
  ),
];

/// https://gist.github.com/maciekish/66b6deaa7bc979d0a16c50784e16d697
const resetXcode = r'''
killall Xcode
xcrun -k
xcodebuild -alltargets clean
rm -rf "$(getconf DARWIN_USER_CACHE_DIR)/org.llvm.clang/ModuleCache"
rm -rf "$(getconf DARWIN_USER_CACHE_DIR)/org.llvm.clang.$(whoami)/ModuleCache"
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf ~/Library/Caches/com.apple.dt.Xcode/*
open /Applications/Xcode.app''';

/// Initialize a git repository and commit all files
const gitInit = r'''
git init
git add .
git commit -m "Initial commit"''';

/// Gradle sync
const gradleSync = r'''
./gradlew prepareKotlinBuildScriptModel''';

/// Ensure ports are free and start Firebase emulators with caching
const fbemu = r'''
lsof -t -i tcp:9099 | xargs kill
lsof -t -i tcp:5001 | xargs kill
lsof -t -i tcp:9000 | xargs kill
lsof -t -i tcp:9098 | xargs kill
lsof -t -i tcp:8087 | xargs kill

firebase emulators:start --export-on-exit=emcache --import=emcache''';
