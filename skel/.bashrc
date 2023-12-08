#!/bin/bash

# Autocomplete pass
source /usr/share/bash-completion/completions/pass

# GPG agent will be used for SSH auth (enables Yubikey auth for ssh)
export SSH_AUTH_SOCK=${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent.ssh
