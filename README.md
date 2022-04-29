# bash-library
A repo of useful libraries that I've been creating through the years to make bash scripting duties easier.

(Yes, I know, `zsh` exists and all, but its not the point, feel free to adapt).

Most of those scripts are kept up-to-date at various times but I try to maintain it to date with latest bash versions.

Each proposed library has its own documentation, read it carefully before using them.

## Dependencies and sourced files
All scripts dependencies are written down in their documentation.

Some scripts are sourcing some other files from this library, making them unusable as-is, but you can use the tool `package_scripts.sh` to compile a standalone version.

All scripts that have sourced files are taking them from this library, and this library only, but using the defined variables from the profiles provided in the `bin` directory.
Please check the [usage section](#usage) for more information.

## Structure
- libraries (to be sourced).
- packages (to be sourced).
- some completion scripts (incl. for *some* previous items listed, to be sourced).
- animation scripts (to be sourced).
  - ... and launchers for those animations to have a preview and how to use them (kind of).
- utility scripts (incl `debug.sh` and bash unit testing framework).
- Third party software helpers (`tools-lib`) to add extra commands to them or
  ease their use (to  be sourced).
- some wild bash tests to be kept for information and posterity.
- some miscellaneous tools.

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

Have fun, stay scripty!
