# Homebrew
set -l brew_bin /opt/homebrew/bin/brew
if test (uname -m) = x86_64
    set brew_bin /usr/local/bin/brew
end
eval ($brew_bin shellenv)

if status is-interactive
    __dotfiles_apply_fish_theme tokyonight
end
