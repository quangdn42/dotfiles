function ytpause --description "Sleep timer to pause media via macOS Shortcuts"
    set -l duration 30m
    if set -q argv[1]
        set duration $argv[1]
    end
    sleep $duration; and shortcuts run "Pause Media"
end
