# TokyoNight Color Palette
set -l foreground c0caf5
set -l selection 283457
set -l comment 565f89
set -l red f7768e
set -l orange ff9e64
set -l yellow e0af68
set -l green 9ece6a
set -l purple 9d7cd8
set -l cyan 7dcfff
set -l pink bb9af7

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
set -g fish_pager_color_selected_background --background=$selection

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
