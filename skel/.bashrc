#!/bin/bash

# Make sure permissions are alright
find ~/.gnupg -type f -exec chmod 600 {} \;
find ~/.gnupg -type d -exec chmod 700 {} \;
find ~/.ssh -type f -exec chmod 600 {} \;
find ~/.ssh -type d -exec chmod 700 {} \;

# Autocomplete pass
source /usr/share/bash-completion/completions/pass

# Add golang bin dir to PATH
export PATH="$PATH:$(go env GOPATH)/bin"

# GPG agent will be used for SSH auth (enables Yubikey auth for ssh)
export SSH_AUTH_SOCK=${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent.ssh

# Shortcuts/etc
alias docker-compose='docker compose'

# Colorize
alias grep='grep --color'
alias l='exa -a --group-directories-first --colour=always --icons'
alias less='less -R'
alias ll='exa -al --group-directories-first --colour=always --icons'
alias ls='ls --color=auto'
alias tree='tree -C'

# Source ls colors from https://github.com/trapd00r/LS_COLORS
source /usr/local/bin/lscolors.sh

# Starship prompt
eval "$(starship init bash)"

# Set window title to the current path when at prompt
function set_window_title(){
	echo -ne "\033]0; $PWD \007"
}
starship_precmd_user_func="set_window_title"

# Set window title to currently running command
trap 'echo -ne "\033]2;$PWD > $(history 1 | sed "s/^[ ]*[0-9]*[ ]*//g")\007"' DEBUG

# Display some system data on terminal start
neofetch --ascii_distro tux --ascii_colors=distro --ascii_bold on --disable icons theme --os_arch on --cpu_temp C --uptime_shorthand tiny --memory_percent on --backend ascii
