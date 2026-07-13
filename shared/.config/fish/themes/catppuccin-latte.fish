# https://github.com/catppuccin/fish/blob/main/themes/static/catppuccin-latte.theme
set -l theme_foreground 4c4f69
set -l theme_selection ccd0da
set -l theme_comment 8c8fa1
set -l theme_muted 9ca0b0
set -l theme_red d20f39
set -l theme_orange fe640b
set -l theme_yellow df8e1d
set -l theme_green 40a02b
set -l theme_blue 1e66f5
set -l theme_purple 8839ef
set -l theme_cyan 179299
set -l theme_pink ea76cb

set -l theme_fish_command $theme_blue
set -l theme_fish_keyword $theme_purple
set -l theme_fish_quote $theme_green
set -l theme_fish_redirection $theme_pink
set -l theme_fish_end $theme_orange
set -l theme_fish_option $theme_green
set -l theme_fish_param dd7878
set -l theme_fish_operator $theme_pink
set -l theme_fish_escape e64553
set -l theme_fish_cwd $theme_yellow
set -l theme_fish_user $theme_cyan
set -l theme_fish_host $theme_blue
set -l theme_fish_host_remote $theme_green

source (status dirname)/_apply.fish
