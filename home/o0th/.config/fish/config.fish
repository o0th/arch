if status is-interactive

	# Start tmux on startup
	if not set -q TMUX
		exec tmux
	end

	# Remove greeting message
	set -U fish_greeting

	# Source starship
	starship init fish | source

	# Source zoxide
	zoxide init fish | source
	alias cd='z'

	# Source fnm
	fnm env | source

	# vi mode
	fish_vi_key_bindings

	# Path
	fish_add_path ~/.cargo/bin

	# Aliases
	alias v='nvim'
	alias dot='/usr/bin/git --git-dir=/home/o0th/.dotfiles --work-tree=/'
end
