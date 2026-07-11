# Platform-specific environment and theme config.
set -l platform_config $HOME/.config/fish/platform.fish
if test -f $platform_config
    source $platform_config
end

set -gx BAT_THEME ansi

# PATH
fish_add_path -g ~/.local/share/nvim/mason/bin

if status is-interactive
  # Commands to run in interactive sessions can go here

	set -g fish_key_bindings fish_vi_key_bindings
	set -g fish_greeting # disable fish greeting

	# abbr & alias
	abbr --add ls lsd
	abbr --add tree lsd --tree
	abbr --add la lsd -lA
	abbr --add lg lazygit
	abbr --add cl curlie
	abbr --add wtt wezterm cli set-tab-title
	abbr --add wwt wezterm cli rename-workspace
	abbr --add gdoc 'stdsym | fzf --preview "go doc \$(echo {})" | xargs go doc'
	abbr --add j jj
	abbr --add js jj st
	abbr --add je jj edit
	abbr --add jn jj new
	abbr --add jl jj log -n 10
	abbr --add jd jj diff
	abbr --add jsq jj squash
	abbr --add jsqi jj squash -i
	alias v nvim
	alias n 'NVIM_APPNAME="lazyvim" nvim'
	abbr --add dotdot --regex '^\.\.+$' --function multicd

	# man syntax highlighting
	set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"

	set -gx XDG_CONFIG_HOME $HOME/.config # for lazygit to use correct config folder


	# fzf --fish | FZF_ALT_C_COMMAND= source
	set -g FZF_DEFAULT_OPTS '--bind=up:previous,down:next'
	zoxide init fish | source
end
