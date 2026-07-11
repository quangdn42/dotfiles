# Overwrite parts of the omarchy-menu with user-specific behavior.
# This function is sourced only inside omarchy-menu, so it does not shadow the
# real command elsewhere.

scale_walker_dimension() {
  case "$1:$2" in
    --width:295) printf '%s\n' 443 ;;
    --width:644) printf '%s\n' 966 ;;
    --width:800) printf '%s\n' 1200 ;;
    --minheight:300) printf '%s\n' 450 ;;
    --minheight:400) printf '%s\n' 600 ;;
    --maxheight:300) printf '%s\n' 450 ;;
    --maxheight:500) printf '%s\n' 750 ;;
    --maxheight:630) printf '%s\n' 945 ;;
    *) printf '%s\n' "$2" ;;
  esac
}

omarchy-launch-walker() {
  local args=()

  while (( $# > 0 )); do
    case "$1" in
      --width|--minheight|--maxheight)
        if (( $# > 1 )); then
          args+=("$1" "$(scale_walker_dimension "$1" "$2")")
          shift 2
        else
          args+=("$1")
          shift
        fi
        ;;
      --width=*|--minheight=*|--maxheight=*)
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

  command omarchy-launch-walker "${args[@]}"
}
