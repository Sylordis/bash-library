#! /usr/bin/env bash

# This script checks in a git repository for java classes (not containing 'Test'),
# compares the current version with the baseline version via a `git show` and sdiff
# to calculate the lines changed percentage, then goes to fetch the jacoco csv
# report to fetch the numbers on lines missed and covered to calculate the coverage:
#      coverage (in %) = covered/(missed+covered)
# This script outputs on standard stream. If not used with the aggregator, you might want
# to redirect or `tee` it somewhere.
#
# The folder structure under the jacoco reports directory should be:
#  jacoco-reports-dir/<repo>/<package>/jacoco-results
# This is achieved on the machine that produced the unit tests via:
#   cd <building workspace>
#   find -type d -name 'jacoco-results' -exec cp -r --parents {} <workspace> \;
#

source "$SH_PATH_LIB/check_dependencies.sh"
if [[ -f "$SH_DEBUG" ]]; then
  source "$SH_DEBUG" # pack:noreplace
else
  debug() { :; }
fi

# Displays basic usage
usage() {
  #   $1    Path to git repo
  #   $2    Path to jacoco reports of git repo
  #   $3    Commit to check from
  echo "usage: $(basename "$0") <git-repo> <jacoco-reports-dir> <baseline-revision>"
  if [[ "$1" == '-f' ]]; then
    echo "  with
    git-repo
      Directory of the git repo under coverage test.
    jacoco-reports-dir
      Directory with jacoco reports in it.
    baseline-revision
      Git revision (commit id or tag) to check the differences from."
  fi
}

# Jacoco report CSV column index for missed
INDEX_MISSED=8
# Jacoco report CSV column index for covered
INDEX_COVERED=9

# Retrieves the statistics of coverage from the Jacoco CSV report.
#   $1    Path to jacoco reports
#   $2    File
get_file_coverage() {
  local csvfile="$1/$(cut -d '/' -f 2 <<< "$2")/jacoco-results/report.csv"
  local classname
  local missed covered coverage csvline t_missed t_covered
  classname="$(basename "${2%.java}")"
  # If the reports exists
  if [[ -r "$csvfile" ]]; then
    missed=0
    covered=0
    # Some files appear multiple times in the report (internal classes), summing it all up
    while read -r csvline; do
      t_missed="$(cut -d , -f $INDEX_MISSED <<< "$csvline")"
      t_covered="$(cut -d , -f $INDEX_COVERED <<< "$csvline")"
      missed=$((missed + t_missed))
      covered=$((covered + t_covered))
    done < <(grep ",$classname," "$csvfile")
    if [[ $covered -eq 0 ]] && [[ $missed -eq 0 ]]; then
      coverage=0
    else
      coverage="$(bc <<< "100*$covered/($missed+$covered)")"
    fi
      else
    missed='N/A'
    covered='N/A'
    coverage=0
  fi
  echo ",$missed,$covered,${coverage}%"
}

#   $1    Path to git repo
#   $2    Path to jacoco reports of git repo
#   $3    Commit to check from
parse_all_files() {
  local first_commit
  pushd "$1" > /dev/null
  first_commit="$3"
    # first_commit="FOC2_WP3X_BASELINE"
  # first_commit="$(git log --reverse --pretty="%H" | head -1)"
  while read -r file; do
    echo -n "$(parse_file_diff_from "$file" "$first_commit" HEAD)"
    echo "$(get_file_coverage "$2" "$file")"
  done < <(find -type f -name '*.java' -not -name '*Test*')
  popd > /dev/null
}

#   $1    Path to file
#   $2    Commit 1
#   $3    Commit 2
parse_file_diff_from() {
    local added deleted path nlines
  nlines="$(wc -l < "$1")"
    read -r added deleted path <<< $(git diff --numstat "$2".."$3" -- "$1")
    if [[ ${added-0} -eq $nlines ]]; then
    nlines_changed=$nlines
    percent=100
  else
    nlines_changed="$(sdiff -B -b -s <(git show "$2:$1") <(git show "$3:$1") | wc -l)"
    if [[ $nlines -eq 0 ]]; then
      nlines_changed="deleted"
      percent="deleted"
    else
      percent=$(bc <<< "100*$nlines_changed/$nlines")
    fi
  fi
    echo "$(cut -d '/' -f 2 <<< "$1"),$(basename "${1%.java}"),$nlines_changed,$nlines,${percent}%"
}

# Options check
while : ; do
  case "$1" in
    --debug) DEBUG_MODE=0;;
    --help) usage -f; exit 0;;
         *) break;;
  esac
  shift
done

# Args check
if [[ "$#" -lt 3 ]]; then
  echo "ERROR: Wrong number of arguments." >& 2
  usage
  exit 1
fi

check_dependencies basename bc cut find git sdiff wc || exit 1

echo "package,file,lines changed,size,%change,lines missed,lines covered,%coverage"
parse_all_files "$@"
