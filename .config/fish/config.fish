# install fisher https://github.com/jorgebucaran/fisher
# fisher install ilancosman/tide@v6 or plttn/tide@v6
# fisher install lewisacidic/fish-git-abbr
# fisher install PatrickF1/fzf.fish

if status is-interactive
  # Commands to run in interactive sessions can go here

	set -g fish_key_bindings fish_vi_key_bindings
	set -g fish_greeting # disable fish greeting

	source $HOME/.config/fish/themes/tokyonight.fish

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
	abbr --add j jj
	abbr --add jl jj log
	abbr --add jd jj diff
	abbr --add jsq jj squash
	alias v nvim
	alias n 'NVIM_APPNAME="lazyvim" nvim'
	alias fn 'NVIM_APPNAME="firenvim" nvim'
	alias zig0.14 '~/workspaces/zig-aarch64-macos-0.14.1/zig'
	alias python python3.12
	abbr --add dotdot --regex '^\.\.+$' --function multicd

	# man syntax highlighting
	set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"

	# EDITOR
	set -Ux EDITOR vim

	# PATH
	set -gx PATH $PATH ~/.local/share/nvim/mason/bin /opt/homebrew/bin ~/.zvm/bin
	set -gx XDG_CONFIG_HOME $HOME/.config # for lazygit to use correct config folder

	# fzf --fish | FZF_ALT_C_COMMAND= source
	set -g FZF_DEFAULT_OPTS '--bind=up:previous,down:next'
	zoxide init fish | source
end
