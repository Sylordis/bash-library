_go_completion() {
  if [[ $COMP_CWORD -eq 2 ]]; then
    local var_name="$(tr '[:lower:]' '[:upper:]' <<< "${COMP_WORDS[1]}")_HOME"
    local curr_dir="${!var_name}"
    COMPREPLY=($(compgen -W "$(find "$curr_dir" -maxdepth 1 -type d | \
        rev | cut -d '/' -f 1 | rev)" "${COMP_WORDS[$COMP_CWORD]}"))
  elif [[ $COMP_CWORD -eq 1 ]]; then
    _vars=($(compgen -A variable \
        | grep --color=never -E "^.*_HOME$|GO_DYN_PATH_.*" \
        | sed -re 's/_HOME$|^GO_DYN_PATH_//g' \
        | tr '[:upper:]' '[:lower:]'))
    COMPREPLY=($(compgen -W "${_vars[*]}" "${COMP_WORDS[1]}"))
  fi
}
complete -F _go_completion go
