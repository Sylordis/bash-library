#!/usr/bin/env awk

# This replace all sourced files from a file, unless they are followed by the comment
# pack:noreplace.

BEGIN {
  regex=".*# *pack:noreplace( +.*)?";
}
{
  if ($1 == "source" && !(match($0, regex))) {
    if (match($2, "\".*\"")) {
      # Remove quotes
      path = substr($2, RSTART+1, RLENGTH-2)
    } else {
      path=$2
    }
    # Replace all variables in the path
    while (match(path, /^\$[A-Za-z0-9_]+/) > 0) {
      varname = substr(path, RSTART+1, RLENGTH-1)
      pattern = "\\$" varname
      varvalue = ENVIRON[varname]
      gsub(pattern, varvalue, path)
    }
    # Print actual file without shebang
    system("grep -v '#!' " path)
  } else {
    # Print the line if it's not a source instruction
    print
  }
}
