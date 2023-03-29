#! /usr/bin/env bash

# This script is an aggregator to "create_change_coverage_report.sh", which should
# be located in the same folder.
# It tees all output to one file (see GLOBAL_RESULT_FILE variable).
#
# The folder structure under the jacoco reports directory should be:
#  jacoco-reports-dir/<repo>/<package>/jacoco-results
# This is achieved on the machine that produced the unit tests via:
#   cd /data/build_manager/projects
#   find -type d -name 'jacoco-results' -exec cp -r --parents {} <workspace> \;
#

source "$SH_PATH_LIB/check_dependencies.sh"

# Displays basic usage
usage() {
  echo "usage: $(basename "$0") <Repo-workspace> <UT-workspace> <Baseline revision>"
  if [[ "$1" == "-f" ]]; then
    echo "  with
    repo-workspace
      Workspace containing all repos.
    UT-workspace
      Workspace/parent directory containing all unit tests reports from jacoco.
      See inline doc.
    Baseline revision
      Git revision (commit id or tag) to check the differences from."
  else
    echo "  Use --help for full usage."
  fi
}
RESULT_FILE='change-coverage.csv'
GLOBAL_RESULT_FILE='global-change-coverage.csv'
CURRENT_DIR="$(dirname "$0")"

# Options check
while : ; do
  case "$1" in
    --help) usage -f; exit 0;;
         *) break;;
  esac
  shift
done

# Args check
if [[ $# -lt 3 ]]; then
  echo "ERROR: Wrong number of arguments." >& 2
  usage
  exit 1
fi

check_dependencies basename dirname find tail tee || exit 1

# Parse each repos
while read -r repo; do
  repo_name="$(basename "$repo")"
  echo $repo_name
  # Call subscript
  "$CURRENT_DIR"/create_change_coverage_report.sh \
      "$1/$repo_name" "$2/$repo_name" "$3"\
      | tee -a "$2/$repo_name/$RESULT_FILE"
done < <(find "$2" -maxdepth 1 -mindepth 1 -type d)

# Create global result file with header
echo "package,file,lines changed,size,%change,lines missed,lines covered,%coverage" \
    > "$2/$GLOBAL_RESULT_FILE"
# Aggregate all result files without the header
find "$2" -name "$RESULT_FILE" -type f | xargs tail -q -n+2 >> "$2/$GLOBAL_RESULT_FILE"
