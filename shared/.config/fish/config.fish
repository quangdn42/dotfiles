set -gx BAT_THEME ansi

# PATH
if set -l local_bin_index (contains -i -- $HOME/.local/bin $PATH)
    set -e PATH[$local_bin_index]
end
set -gx PATH $HOME/.local/bin $PATH

if type -q mise
    mise activate fish | source
end

if status is-interactive
  # Commands to run in interactive sessions can go here

	set -g fish_key_bindings fish_vi_key_bindings
	set -g fish_greeting # disable fish greeting

	# abbr & alias
	abbr --add ls "lsd --group-directories-first"
	abbr --add ll "lsd -lh --group-directories-first"
	abbr --add la "lsd -lAh --group-directories-first"
	abbr --add lt "lsd --tree --depth=3"
	abbr --add lag "lsd -lAh --group-directories-first --git"
	abbr --add lg lazygit
	abbr --add cl curlie
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
	alias zed zeditor
	alias oc opencode
	alias co codex
	abbr --add dotdot --regex '^\.\.+$' --function multicd

	# man syntax highlighting
	set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"

	set -gx XDG_CONFIG_HOME $HOME/.config # for lazygit to use correct config folder

	# fzf --fish | FZF_ALT_C_COMMAND= source
	# set -g FZF_DEFAULT_OPTS '--bind=up:previous,down:next'
	zoxide init fish | source
end
