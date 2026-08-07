# Homebrew
for brew_prefix in /opt/homebrew /usr/local
    set -l brew_bin "$brew_prefix/bin/brew"

    if test -x $brew_bin
        eval ($brew_bin shellenv)
        break
    end
end