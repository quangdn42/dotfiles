# https://github.com/rebelot/kanagawa.nvim/blob/master/extras/fish/kanagawa.fish
set -l theme_foreground dcd7ba
set -l theme_selection 2d4f67
set -l theme_comment 727169
set -l theme_muted 727169
set -l theme_red c34043
set -l theme_orange ff9e64
set -l theme_yellow c0a36e
set -l theme_green 76946a
set -l theme_blue 7e9cd8
set -l theme_purple 957fb8
set -l theme_cyan 7aa89f
set -l theme_pink d27e99

set -l theme_fish_command $theme_cyan
set -l theme_fish_keyword $theme_pink
set -l theme_fish_quote $theme_yellow
set -l theme_fish_redirection $theme_foreground
set -l theme_fish_end $theme_orange
set -l theme_fish_option $theme_pink
set -l theme_fish_param $theme_purple
set -l theme_fish_operator $theme_green
set -l theme_fish_escape $theme_pink
set -l theme_fish_cwd $theme_cyan
set -l theme_fish_user $theme_yellow
set -l theme_fish_host $theme_green
set -l theme_fish_host_remote $theme_green

source (status dirname)/_apply.fish
