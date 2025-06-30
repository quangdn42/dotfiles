# install fisher https://github.com/jorgebucaran/fisher
# fisher install ilancosman/tide@v6
# fisher install lewisacidic/fish-git-abbr
# fisher install PatrickF1/fzf.fish

if status is-interactive
  # Commands to run in interactive sessions can go here

	set -g fish_key_bindings fish_vi_key_bindings
	set -g fish_greeting # disable fish greeting

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

	# Completion Pager Colors
	set -g fish_pager_color_progress $comment
	set -g fish_pager_color_prefix $cyan
	set -g fish_pager_color_completion $foreground
	set -g fish_pager_color_description $comment
	set -g fish_pager_color_selected_background --background=$selection

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

	# yazi
	function y
		set tmp (mktemp -t "yazi-cwd.XXXXXX")
		yazi $argv --cwd-file="$tmp"
		if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
			builtin cd -- "$cwd"
		end
		rm -f -- "$tmp"
	end

	# abbr & alias
	abbr --add ls lsd
	abbr --add tree lsd --tree
	abbr --add la lsd -lA
	abbr --add lg lazygit
	abbr --add cl curlie
	abbr --add wtt wezterm cli set-tab-title
	abbr --add wwt wezterm cli rename-workspace
	abbr --add gdoc 'stdsym | fzf --preview "go doc \$(echo {})" | xargs go doc'
	abbr --add runkanata 'sudo kanata -d --cfg ~/dotfiles/.config/kanata/sym-only.kbd --quiet'
	alias v nvim
	alias n 'NVIM_APPNAME="lazyvim" nvim'
	alias fn 'NVIM_APPNAME="firenvim" nvim'
	function multicd
		echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)
	end
	abbr --add dotdot --regex '^\.\.+$' --function multicd

	# man syntax highlighting
	set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"

	# EDITOR
	set -Ux EDITOR vim

	# PATH
	set -gx PATH $PATH ~/.local/share/nvim/mason/bin
	set -gx PATH $PATH /opt/homebrew/bin
	set -gx XDG_CONFIG_HOME $HOME/.config # for lazygit to use correct config folder

	# fzf --fish | FZF_ALT_C_COMMAND= source
	set -g FZF_DEFAULT_OPTS '--bind=up:previous,down:next'
	zoxide init fish | source
end
