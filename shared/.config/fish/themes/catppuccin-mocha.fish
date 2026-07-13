# https://github.com/catppuccin/fish/blob/main/themes/catppuccin-mocha.theme
set -l theme_foreground cdd6f4
set -l theme_selection 313244
set -l theme_comment 7f849c
set -l theme_muted 6c7086
set -l theme_red f38ba8
set -l theme_orange fab387
set -l theme_yellow f9e2af
set -l theme_green a6e3a1
set -l theme_blue 89b4fa
set -l theme_purple cba6f7
set -l theme_cyan 94e2d5
set -l theme_pink f5c2e7

set -l theme_fish_command $theme_blue
set -l theme_fish_keyword $theme_purple
set -l theme_fish_quote $theme_green
set -l theme_fish_redirection $theme_pink
set -l theme_fish_end $theme_orange
set -l theme_fish_option $theme_green
set -l theme_fish_param f2cdcd
set -l theme_fish_operator $theme_pink
set -l theme_fish_escape eba0ac
set -l theme_fish_cwd $theme_yellow
set -l theme_fish_user $theme_cyan
set -l theme_fish_host $theme_blue
set -l theme_fish_host_remote $theme_green

source (status dirname)/_apply.fish
