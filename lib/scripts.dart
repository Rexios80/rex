/// Script map
const scriptMap = {
  'reset-xcode': resetXcode,
  'git-init': gitInit,
  'gradle-sync': gradleSync,
};

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
./gradlew prepareKotlinBuildScriptModel
''';
