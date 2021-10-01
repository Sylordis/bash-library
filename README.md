# bash-library
A repo of useful libraries that I've been creating through the years to make bash scripting duties easier.

(Yes, I know, `zsh` exists and all, but its not the point, feel free to adapt).

It offers:
- libraries (to be sourced).
- packages (to be sourced).
- some completion scripts (incl. for *some* previous items listed, to be sourced).
- animation scripts (to be sourced).
  - ... and launchers for those animations to have a preview and how to use them (kind of).
- utility scripts (incl `debug.sh` and bash unit testing framework).
- Third party software helpers (`tools-lib`) to add extra commands to them or
  ease their use (to  be sourced).
- some wild bash tests to be kept for information and posterity.
- some misc tools.

Most of those scripts are kept up-to-date at various times but I try to maintain it to date with latest bash versions.

Everything in the libraries and packages have been unit tested (as much as one can with bash).

Each proposed library has its own documentation, read it carefully before using them.

- File `launcher.sh` allows to run all/some unit tests or get the list.
- File `source_libs.sh` allows to source all libs and completion files.
- `.launcher_profile` (and its `safe` counterpart) allow to dynamically create environment variables to use all libs in this repo.
  - The `safe` version prevents from overriding your own environment, but does not output any error. It is sourced in both `launcher.sh` and `source_libs.sh` files.

Have fun, stay scripty!
