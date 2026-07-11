# Homebrew
set -l brew_bin /opt/homebrew/bin/brew
if test (uname -m) = x86_64
    set brew_bin /usr/local/bin/brew
end
eval ($brew_bin shellenv)

if status is-interactive
    source $HOME/.config/fish/themes/tokyonight.fish
end
