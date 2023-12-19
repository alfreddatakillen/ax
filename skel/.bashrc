#!/bin/bash

# Git config
git config --global init.defaultBranch main

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

# Colorize
alias ls='ls --color=auto'

# Starship prompt
eval "$(starship init bash)"

