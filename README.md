This package will not be published due to it being specific to my own needs, but feel free to use it if it suits your needs.

```console
$ rex -h
Tailored convenience commands for developer Rexios

Usage: rex <command> [arguments]

Global options:
-h, --help    Print this usage information.

Available commands:
  create   Create a new project
  open     Open a project in in VSCode and Sublime Merge
  switch   Open a project reusing the current windows

Run "rex help <command>" for more information about a command.
```

Installation:
- Clone this repository
- Run `dart pub global activate --source path .` in the repository

Requirements:
- `open`, `switch`
  - [VSCode](https://code.visualstudio.com/)
  - [Sublime Merge](https://www.sublimemerge.com/)
- `create dart/flutter`
  - [dart](https://dart.dev/)
  - [flutter](https://flutter.dev/)
  - [git](https://git-scm.com/)

Differences from `dart/flutter create`:
- Sanitizes generated `pubspec.yaml`
- Replaces `lints`/`flutter_lints` with `rexios_lints`
- Adds a `LICENSE` to packages
- Runs `git init`, `git add .`, and `git commit -m "Initial commit"`