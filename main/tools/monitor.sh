#! /bin/bash

# This script allows to monitor several processes, i.e. launching a top process for the processes id corresponding to the processes names.

# Displays basic usage
usage() {
  echo "Usage: $(basename "$0") <ps..>"
}

# Argument checks
if [[ $# -eq 0 ]]; then
  echo "ERROR: Wrong number of arguments." >& 2
  usage
  exit 1
fi

# Form the grep chain
procs_grep="$(printf "|%s" "$@")"

# Scout for process ids
procs_ids=($(ps -ef | grep "${procs_grep:1}" | grep "/usr" | grep -v "$0" | awk '{print $2}'))
# No processes found
if [[ "${#procs_ids[@]}" -eq 0 ]]; then
  echo "INFO: Given processes do not exist. Exiting."
  exit 0
fi

# echo "[$procs_ids] |v|:${#procs_ids[@]} v:[${procs_ids[@]}]"

# Form top command
cmd="top -d 2 -p ${procs_ids[0]}"
for pr in ${procs_ids[@]:1}; do
  cmd+=",$pr"
done
# Launch command
# echo "$cmd"
$cmd
