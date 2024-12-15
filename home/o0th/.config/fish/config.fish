if status is-interactive

	# Start tmux on startup
	if not set -q TMUX
		exec tmux
	end

	# Remove greeting message
	set -U fish_greeting

	# Start starship
	starship init fish | source
	fnm env | source

	# Path
	fish_add_path ~/.cargo/bin

	# Aliases
	alias v='nvim'
	alias dot='/usr/bin/git --git-dir=/home/o0th/.dotfiles --work-tree=/'
end
