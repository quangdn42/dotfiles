# https://github.com/folke/tokyonight.nvim/blob/main/extras/fish/tokyonight_night.fish
set -l theme_foreground c0caf5
set -l theme_selection 283457
set -l theme_comment 565f89
set -l theme_muted 565f89
set -l theme_red f7768e
set -l theme_orange ff9e64
set -l theme_yellow e0af68
set -l theme_green 9ece6a
set -l theme_blue 7aa2f7
set -l theme_purple 9d7cd8
set -l theme_cyan 7dcfff
set -l theme_pink bb9af7

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
