# bash-library
A repo of useful libraries that I've been creating through the years to make bash scripting duties easier.

(Yes, I know, `zsh` exists and all, but its not the point, feel free to adapt).

Most of those scripts are kept up-to-date at various times but I try to maintain it to date with latest bash versions.

Each proposed library has its own documentation, read it carefully before using them.

## What you can find here
- executables destined to help use this library.
- libraries (to be sourced).
- packages (to be sourced).
- some completion scripts (incl. for *some* previous items listed, to be sourced).
- animation scripts (to be sourced).
  - ... and launchers for those animations to have a preview and how to use them (kind of).
- utility scripts (incl `debug.sh` and bash unit testing framework).
- Third party software helpers (`tools-lib`) to add extra commands to them or ease their use (to  be sourced).
- some wild bash tests to be kept for information and posterity.
- some miscellaneous tools.

## Dependencies and sourced files
All scripts dependencies are written down in their documentation.

Some scripts are sourcing some other files from this library, making them unusable as-is, but you can use the tool `package_scripts.sh` to compile a standalone version.

All scripts that have sourced files are taking them from this library, and this library only, but using the defined variables from the profiles provided in the `bin` directory.
Please check the [usage section](#usage) for more information.

## Detailed structure
- `bin` executables to help using this repo.
  - `animations` executables to showcase the animation source files.
- `man` manual pages.
- `src` directory containing all source files. None of them are executables.
  - `animation` bash animations in order to prettify waiting for other processes.
  - `awk` awk source files
  - `completion` completion files for some `lib` or `packages`.
  - `lib` core source files of this library, each file contains a method of the same name and maybe some quality-of-life shortcuts.
  - `packages` core source files of this library for frameworks and bigger libraries that contain more than one method.
- `test` unit tests for the source files (libs and packages).
- `tools` random tools for every day life as executables. Some can use sources from this repo.
- `tools-lib` sources for quality of life regarding every day CLI softwares.
- `utils` utilitaries files that are used in this repo. This is where you can find the `debug.sh` script which helps you dumping bash variables.
- `wild` wild bash tests for posterity and bash/console behaviours.

## Development and testing
Everything in the libraries and packages has been unit tested (as much as one can with bash) and can be checked from the `./bin/launcher.sh`.

All development and testing is done using Cygwin, give me a shout if something is not working on standard Linux platforms (feel free to open an issue).

## Usage
- File `launcher.sh` allows to run all/some unit tests or get the list.
- File `source_libs.sh` allows to source all libs and completion files.
- `.launcher_profile` (and its `safe` counterpart) allow to dynamically create environment variables to use all libs in this repo.
  - The `safe` version prevents from overriding your own environment, but does not output any error. It is sourced in both `launcher.sh` and `source_libs.sh` files.

A small excerpt from my `.bashrc` to use this repo:
```sh
export SH_PATH=~/scripts/main
source "$SH_PATH/bin/source_libs.sh"

alias reload='source ~/.bashrc'
alias bashtest='$SH_PATH/bin/launcher.sh'
```

# Help

Each file should have its own documentation and some man pages are being created (when time allows).

# Author & contributors

The only contributor and author is Sylvain "Sylordis" Domenjoud.

# License

This project is distributed under the [DBAD license](https://dbad-license.org/).

# Bug report

Please report any bug you find at https://github.com/Sylordis/bash-library/issues

Have fun, stay scripty!
