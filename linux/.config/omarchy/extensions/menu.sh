# Overwrite parts of the omarchy-menu with user-specific behavior.
# This function is sourced only inside omarchy-menu, so it does not shadow the
# real command elsewhere.

scale_walker_dimension() {
  if [[ $2 =~ ^[0-9]+$ ]] && (( $2 > 1 )); then
    printf '%s\n' $(( ($2 * 3 + 1) / 2 ))
  else
    printf '%s\n' "$2"
  fi
}

scale_walker_args() {
  local args=()

  while (( $# > 0 )); do
    case "$1" in
      --width|--height|--minwidth|--maxwidth|--minheight|--maxheight)
        if (( $# > 1 )); then
          args+=("$1" "$(scale_walker_dimension "$1" "$2")")
          shift 2
        else
          args+=("$1")
          shift
        fi
        ;;
      --width=*|--height=*|--minwidth=*|--maxwidth=*|--minheight=*|--maxheight=*)
        local key="${1%%=*}"
        local value="${1#*=}"
        args+=("$key=$(scale_walker_dimension "$key" "$value")")
        shift
        ;;
      *)
        args+=("$1")
        shift
        ;;
    esac
  done

  if (( ${#args[@]} > 0 )); then
    printf '%s\0' "${args[@]}"
  fi
}

omarchy-launch-walker() {
  local args=()
  mapfile -d '' -t args < <(scale_walker_args "$@")

  command omarchy-launch-walker "${args[@]}"
}

walker() {
  local args=()
  mapfile -d '' -t args < <(scale_walker_args "$@")

  command walker "${args[@]}"
}
