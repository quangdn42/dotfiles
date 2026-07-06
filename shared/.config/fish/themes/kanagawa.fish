#!/usr/bin/fish

# Kanagawa Fish shell theme
# A template was taken and modified from Tokyonight:
# https://github.com/folke/tokyonight.nvim/blob/main/extras/fish_tokyonight_night.fish
set -l foreground DCD7BA normal
set -l selection 2D4F67 brcyan
set -l comment 727169 brblack
set -l red C34043 red
set -l orange FF9E64 brred
set -l yellow C0A36E yellow
set -l green 76946A green
set -l purple 957FB8 magenta
set -l cyan 7AA89F cyan
set -l pink D27E99 brmagenta

# Syntax Highlighting Colors
set -g fish_color_normal $foreground
set -g fish_color_command $cyan
set -g fish_color_keyword $pink
set -g fish_color_quote $yellow
set -g fish_color_redirection $foreground
set -g fish_color_end $orange
set -g fish_color_option $pink
set -g fish_color_error $red
set -g fish_color_param $purple
set -g fish_color_comment $comment
set -g fish_color_selection --background=$selection
set -g fish_color_search_match --background=$selection
set -g fish_color_operator $green
set -g fish_color_escape $pink
set -g fish_color_autosuggestion $comment
set -g fish_color_cwd $cyan
set -g fish_color_user $yellow
set -g fish_color_host $green
set -g fish_color_host_remote $green

# Completion Pager Colors
set -g fish_pager_color_progress $comment
set -g fish_pager_color_prefix $cyan
set -g fish_pager_color_completion $foreground
set -g fish_pager_color_description $comment

# Tide colors
set -g tide_character_color $green
set -g tide_character_color_failure $red
set -g tide_context_color_root $orange
set -g tide_direnv_color $orange
set -g tide_direnv_color_denied $red
set -g tide_git_color_branch $purple
set -g tide_git_color_conflicted $red
set -g tide_git_color_dirty $orange
set -g tide_git_color_operation $red
set -g tide_git_color_staged $orange
set -g tide_git_color_stash $green
set -g tide_git_color_untracked $purple
set -g tide_git_color_upstream $green
set -g tide_pwd_color_anchors $cyan
set -g tide_pwd_color_dirs $cyan
# set -g tide_right_prompt_items status cmd_duration context jobs direnv node python rustc java php pulumi ruby go kubectl distrobox toolbox terraform aws nix_shell crystal elixir zig
