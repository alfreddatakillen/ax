#!/bin/bash

# Make sure permissions are alright
find ~/.gnupg -type f -exec chmod 600 {} \;
find ~/.gnupg -type d -exec chmod 700 {} \;
find ~/.ssh -type f -exec chmod 600 {} \;
find ~/.ssh -type d -exec chmod 700 {} \;

# Add golang bin dir to PATH
export PATH="$PATH:$(go env GOPATH)/bin"

# The IS_SSH variable is set to "true" if this is an SSH session, otherwise "false":
IS_SSH="false"
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
	IS_SSH="true"
else
	# If the login shell's parent process name is sshd, it's an ssh session:
	case $(ps -o comm= -p "$PPID") in
		sshd|*/sshd) IS_SSH="true";;
	esac
fi
export IS_SSH

# GPG agent will be used for SSH auth (enables Yubikey auth for ssh)
if [ "$IS_SSH" = "false" ]; then
	export SSH_AUTH_SOCK=${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent.ssh
fi

# Shortcuts/etc
alias docker-compose='docker compose'

# Colorize
alias grep='grep --color'
alias l='exa -a --group-directories-first --colour=always --icons'
alias less='less -R'
alias ll='exa -al --group-directories-first --colour=always --icons'
alias ls='ls --color=auto'
alias tree='tree -C'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .......='cd ../../../../../..'
alias ........='cd ../../../../../../..'
alias .........='cd ../../../../../../../..'
alias ..........='cd ../../../../../../../../..'
alias ...........='cd ../../../../../../../../../..'
alias ............='cd ../../../../../../../../../../..'

# Source ls colors from https://github.com/trapd00r/LS_COLORS
source /usr/local/bin/lscolors.sh

# Starship prompt
eval "$(starship init bash)"

# Set window title to the current path when at prompt
function set_window_title(){
	echo -ne "\033]0; $PWD \007"
}
starship_precmd_user_func="set_window_title"

# Autocomplete kubectl, pass
source /etc/bash_completion
source <(kubectl completion bash)
source /usr/share/bash-completion/completions/pass

# Kubernetes aliases
alias k='kubectl'
alias kp='kubectl get pods --all-namespaces -o=wide'

# Use autocompletion for kubectl on alias k as well:
complete -F __start_kubectl k

if [ "$IS_SSH" = "false" ]; then 
	# Set window title to currently running command
	trap 'echo -ne "\033]2;$PWD > $(history 1 | sed "s/^[ ]*[0-9]*[ ]*//g")\007"' DEBUG
fi

# Do not do neofetch on sftp sessions:
if [ "$IS_SSH" = "false" ] || [ "$SSH_TTY" != "" ]; then
	# Display some system data on terminal start
	neofetch --ascii_distro tux --ascii_colors=distro --ascii_bold on --disable icons theme --os_arch on --cpu_temp C --uptime_shorthand tiny --memory_percent on --backend ascii

	echo -ne "\033[38;5;243m"
	fortune anarchism
	echo -e "\033[0m"
fi
if [ "$IS_SSH" = "false" ]; then
	ax
fi

