#!/usr/bin/env bash

# Runs a java maven program via mvn exec:java
# Args:
#   $1    Path to main class
#   $*    Arguments to pass to the executed software
mvnrun() {
  local main_class_path="${1//./'/'}"
  local base_path="target/classes"
  # Make the proper main class argument
  if [[ ! -f "$base_path/$main_class_path.class" ]]; then
    main_class_path="$(find "$base_path" -type f -name "${1##*.}.class" | sed -re "s%${base_path}/(.*).class%\1%g")"
  fi
  # If no main class found, do not wait for maven to tell so
  if [[ -z "$main_class_path" ]]; then
    echo "ERROR: Main class '$1' not found." >& 2
    return 1
  fi
  local main_class="${main_class_path//'/'/.}"
  cmd="mvn exec:java -Dexec.mainClass=\"$main_class\" -Dexec.args=\"${*:2}\""
  debug "$cmd"
  eval "$cmd"
}
