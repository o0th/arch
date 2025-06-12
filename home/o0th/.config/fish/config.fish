if status is-interactive

	# Start tmux on startup
	#if not set -q TMUX
	#	exec tmux
	#end

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
	fish_add_path ~/go/bin
	fish_add_path ~/minio-binaries/
	fish_add_path ~/.pyenv/bin
	fish_add_path ~/.local/share/gem/ruby/3.4.0/bin

	# Aliases
	alias v='nvim'
	alias t='terraform'
	alias k='kubectl'
	alias h='helm'
	alias dot='/usr/bin/git --git-dir=/home/o0th/.dotfiles --work-tree=/'

	# Gem home
	set -gx GEM_HOME ~/.local/share/gem/ruby/3.4.0

	# Go private
	set -Ux GOPRIVATE github.com/ChocOps/libchoc

	while set pyenv_index (contains -i -- "/home/o0th/.pyenv/shims" $PATH)
	set -eg PATH[$pyenv_index]; end; set -e pyenv_index
	set -gx PATH '/home/o0th/.pyenv/shims' $PATH
	command pyenv rehash 2>/dev/null
end
