#!/usr/bin/env awk

# This replace all sourced files from a file, unless they are followed by the comment
# ps:noreplace.

BEGIN {
  regex=".*#ps:noreplace( +.*)?";
}
{
  if ($1 == "source" && !(match($0, regex))) {
    if (match($2, "\".*\"")) {
      # Remove quotes
      path = substr($2, RSTART+1, RLENGTH-2)
    } else {
      path=$2
    }
    # Replace variables
    origpath=path
    while (match(path, /^\$[A-Za-z0-9_]+/) > 0) {
      varname = substr(path, RSTART+1, RLENGTH-1)
      pattern = "\\$" varname
      varvalue = ENVIRON[varname]
      gsub(pattern, varvalue, path)
    }
    system("grep -v '#!' " path)
  } else {
    print
  }
}
