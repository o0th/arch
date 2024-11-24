if status is-interactive
	# Remove greeting message
	set -U fish_greeting

	# Start starship
	starship init fish | source

	alias v='nvim'
	alias dot='/usr/bin/git --git-dir=/home/o0th/.dotfiles --work-tree=/'
end
